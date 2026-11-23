#!/usr/bin/env bash
# Installs the plugin from this checkout into throwaway Claude Code and Codex
# homes, and checks that each host lists every skill in skills/ and the bundled
# docs server marfa-docs, and that the plugin carries no hooks, agents or LSP
# servers.
#
# Usage: scripts/check-install.sh [claude|codex]...  (both when none is named)
# Set CLAUDE or CODEX to run a particular build of either command.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
claude_cmd="${CLAUDE:-claude}"
codex_cmd="${CODEX:-codex}"

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

skills=()
for dir in "${root}"/skills/*/; do
  skills+=("$(basename "${dir}")")
done
if [ "${#skills[@]}" -eq 0 ]; then
  echo "error: no skills found in ${root}/skills" >&2
  exit 1
fi

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

check_claude() {
  local home="${tmp}/claude" details before="${failures}"
  mkdir -p "${home}"
  CLAUDE_CONFIG_DIR="${home}" "${claude_cmd}" plugin marketplace add "${root}" > /dev/null
  CLAUDE_CONFIG_DIR="${home}" "${claude_cmd}" plugin install marfa@withmarfa > /dev/null
  details="$(CLAUDE_CONFIG_DIR="${home}" "${claude_cmd}" plugin details marfa@withmarfa)"

  local expected
  expected="$(printf '%s\n' "${skills[@]}" | sort | paste -sd, - | sed 's/,/, /g')"
  grep -Eq "Skills \(${#skills[@]}\)[[:space:]]+${expected}\$" <<< "${details}" \
    || fail "Claude Code does not list exactly the skills: ${expected}"
  grep -Eq "MCP servers \(1\)[[:space:]]+marfa-docs[[:space:]]" <<< "${details}" \
    || fail "Claude Code does not list exactly the marfa-docs server"
  local component
  for component in "Agents" "Hooks" "LSP servers"; do
    grep -Eq "^[[:space:]]*${component} \(0\)" <<< "${details}" \
      || fail "Claude Code lists ${component} in the plugin"
  done
  [ "${failures}" -gt "${before}" ] || echo "Claude Code: installed marfa@withmarfa with skills ${expected} and marfa-docs"
}

check_codex() {
  local home="${tmp}/codex" prompt before="${failures}"
  mkdir -p "${home}"
  CODEX_HOME="${home}" "${codex_cmd}" plugin marketplace add "${root}" > /dev/null
  CODEX_HOME="${home}" "${codex_cmd}" plugin add marfa@withmarfa > /dev/null
  # Prints the input Codex would send the model, which lists the skills it
  # loaded. It needs no sign-in.
  prompt="$(cd "${tmp}" && CODEX_HOME="${home}" "${codex_cmd}" debug prompt-input "hello" 2> /dev/null)"

  local skill
  for skill in "${skills[@]}"; do
    grep -Eq "marfa:${skill}([^a-z0-9-]|\$)" <<< "${prompt}" \
      || fail "Codex does not list the skill marfa:${skill}"
  done
  local mcp servers
  mcp="$(CODEX_HOME="${home}" "${codex_cmd}" mcp list)"
  grep -Eq '^marfa-docs[[:space:]]+https://docs\.marfa\.so/mcp([[:space:]]|$)' <<< "${mcp}" \
    || fail "Codex does not list marfa-docs at https://docs.marfa.so/mcp"
  servers="$(awk 'NR > 1 && NF { print $1 }' <<< "${mcp}")"
  [ "${servers}" = "marfa-docs" ] \
    || fail "Codex does not list exactly the marfa-docs server: ${servers}"
  [ "${failures}" -gt "${before}" ] || echo "Codex: installed marfa@withmarfa with skills ${skills[*]/#/marfa:} and marfa-docs"
}

hosts=("$@")
if [ "${#hosts[@]}" -eq 0 ]; then
  hosts=(claude codex)
fi
for host in "${hosts[@]}"; do
  case "${host}" in
    claude) check_claude ;;
    codex) check_codex ;;
    *)
      echo "error: unknown host ${host}; use claude or codex" >&2
      exit 2
      ;;
  esac
done

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
