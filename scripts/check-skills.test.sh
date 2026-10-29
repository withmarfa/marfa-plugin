#!/usr/bin/env bash
# Tests scripts/check-skills.sh against skills that pass and skills that break
# each rule it enforces.
set -euo pipefail

script="$(cd "$(dirname "$0")" && pwd)/check-skills.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

failures=0

# Writes one skill directory named $2 under $1, with $3 as the whole SKILL.md.
skill() {
  mkdir -p "$1/$2"
  printf '%s\n' "$3" > "$1/$2/SKILL.md"
}

# Runs the check on directory $2 and compares the outcome with $1 (pass or fail).
expect() {
  local want="$1" dir="$2" label="$3" got
  if "${script}" "${dir}" > /dev/null 2>&1; then got=pass; else got=fail; fi
  if [ "${got}" = "${want}" ]; then
    echo "ok: ${label}"
  else
    echo "not ok: ${label} (expected ${want}, got ${got})" >&2
    failures=$((failures + 1))
  fi
}

case_dir() {
  local dir="${tmp}/$1"
  mkdir -p "${dir}"
  echo "${dir}"
}

d="$(case_dir good)"
skill "${d}" "find-things" $'---\nname: find-things\ndescription: Find things. Use when asked to find things.\nlicense: Apache-2.0\n---\n\n# Find things\n\nLook first.'
skill "${d}" "quoted" $'---\nname: "quoted"\ndescription: \'Quoted values are fine.\'\n---\n\nBody.'
expect pass "${d}" "valid skills pass"

d="$(case_dir mismatch)"
skill "${d}" "find-things" $'---\nname: find-stuff\ndescription: Find things.\n---\n\nBody.'
expect fail "${d}" "a name that differs from its directory fails"

d="$(case_dir uppercase)"
skill "${d}" "Find" $'---\nname: Find\ndescription: Find things.\n---\n\nBody.'
expect fail "${d}" "an uppercase name fails"

d="$(case_dir no-name)"
skill "${d}" "find" $'---\ndescription: Find things.\n---\n\nBody.'
expect fail "${d}" "a missing name fails"

d="$(case_dir no-description)"
skill "${d}" "find" $'---\nname: find\n---\n\nBody.'
expect fail "${d}" "a missing description fails"

d="$(case_dir folded)"
skill "${d}" "find" $'---\nname: find\ndescription: >\n  Find things.\n---\n\nBody.'
expect fail "${d}" "a description over several lines fails"

d="$(case_dir long)"
skill "${d}" "find" "$(printf -- '---\nname: find\ndescription: %s\n---\n\nBody.' "$(printf 'a%.0s' $(seq 1 1025))")"
expect fail "${d}" "a description over 1024 characters fails"

d="$(case_dir host-field)"
skill "${d}" "find" $'---\nname: find\ndescription: Find things.\nmodel: opus\n---\n\nBody.'
expect fail "${d}" "a field only one host reads fails"

d="$(case_dir no-frontmatter)"
skill "${d}" "find" $'# Find\n\nBody.'
expect fail "${d}" "a file with no frontmatter fails"

d="$(case_dir no-body)"
skill "${d}" "find" $'---\nname: find\ndescription: Find things.\n---'
expect fail "${d}" "a skill with no instructions fails"

d="$(case_dir no-file)"
mkdir -p "${d}/find"
expect fail "${d}" "a skill directory with no SKILL.md fails"

d="$(case_dir empty)"
expect fail "${d}" "a directory with no skills fails"

if [ "${failures}" -gt 0 ]; then
  echo "${failures} failed" >&2
  exit 1
fi
