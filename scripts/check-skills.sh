#!/usr/bin/env bash
# Checks the frontmatter of every skills/*/SKILL.md against the Agent Skills
# format that both Claude Code and Codex read: a `name` that matches the
# directory, a `description`, and only the fields both hosts understand.
#
# Usage: scripts/check-skills.sh [skills directory]  (default: skills/)
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dir="${1:-${root}/skills}"
allowed=" name description license compatibility metadata allowed-tools "

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

# Prints the frontmatter between the opening `---` line and the next one, or
# nothing when the file does not start with `---`.
frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

# Prints the value of a top-level field, with surrounding quotes removed.
field() {
  sed -n "s/^$1:[[:space:]]*//p" <<< "$2" | head -n 1 | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/"
}

count=0
for skill_dir in "${dir}"/*/; do
  skill_dir="${skill_dir%/}"
  dirname="$(basename "${skill_dir}")"
  file="${skill_dir}/SKILL.md"
  if [ ! -f "${file}" ]; then
    fail "${dirname}: has no SKILL.md"
    continue
  fi
  count=$((count + 1))

  meta="$(frontmatter "${file}")"
  if [ -z "${meta}" ]; then
    fail "${dirname}: SKILL.md has no frontmatter between --- lines"
    continue
  fi

  while IFS= read -r key; do
    [[ "${allowed}" == *" ${key} "* ]] || fail "${dirname}: field '${key}' is not one both hosts read"
  done < <(sed -n 's/^\([A-Za-z_-][A-Za-z0-9_-]*\):.*/\1/p' <<< "${meta}")

  name="$(field name "${meta}")"
  description="$(field description "${meta}")"

  if [ -z "${name}" ]; then
    fail "${dirname}: has no name"
  else
    [ "${name}" = "${dirname}" ] || fail "${dirname}: name '${name}' does not match its directory"
    [[ "${name}" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "${dirname}: name must be lowercase letters, digits and single hyphens"
    [ "${#name}" -le 64 ] || fail "${dirname}: name is longer than 64 characters"
  fi

  if [ -z "${description}" ]; then
    fail "${dirname}: has no description on the description line"
  elif [[ "${description}" == [\>\|]* ]]; then
    fail "${dirname}: write the description on one line"
  else
    [ "${#description}" -le 1024 ] || fail "${dirname}: description is longer than 1024 characters"
  fi

  [ -n "$(awk 'f && NF { print; exit } /^---$/ { n++; if (n == 2) f = 1 }' "${file}")" ] \
    || fail "${dirname}: has no instructions after the frontmatter"
done

if [ "${count}" -eq 0 ]; then
  fail "no skills found in ${dir}"
fi

if [ "${failures}" -gt 0 ]; then
  exit 1
fi
echo "Checked ${count} skills."
