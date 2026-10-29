# marfa-plugin

The Marfa agent plugin: one plugin source that installs in Claude Code and Codex and carries three skills, `connect`, `find-and-save` and `design-a-type`. It ships nothing that runs: no MCP server entry, hooks, agents or commands. Each Marfa instance serves its own MCP server, and the `connect` skill adds it to the host.

## Layout

- `.claude-plugin/plugin.json` is the plugin manifest and `.claude-plugin/marketplace.json` the marketplace `withmarfa`, whose one entry is this repository (`source: "./"`). Claude Code reads both. Codex reads the same files as its legacy-compatible layout.
- `skills/<name>/SKILL.md` holds each skill, in the Agent Skills format both hosts read. A skill's frontmatter uses only `name`, `description`, `license`, `compatibility`, `metadata` and `allowed-tools`; `name` matches the directory, because Claude Code names a plugin skill by its directory and Codex by its `name`.
- A skill adds judgement, not facts. Facts about Marfa live in its docs (https://docs.marfa.so) and its contract (`conformance/spec/` in withmarfa/marfa), and a skill points there. Check every Marfa name, tool, field and rule a skill states against both before it merges.
- `scripts/check-skills.sh` checks each skill's frontmatter; `scripts/check-skills.test.sh` pins its rules. `scripts/check-install.sh` installs the plugin from the checkout into throwaway Claude Code and Codex homes and checks that each host lists every skill and nothing that runs. Run all three before a pull request.

## CI

- `.github/workflows/ci.yml` runs `Lint workflows and scripts` (actionlint, shellcheck and the pull request description check's tests), `Check skills`, `Validate manifests` (`claude plugin validate --strict`, which fails on warnings) and, once a pull request is ready for review, `Install in Claude Code and Codex`. The workflow pins the versions of both hosts in `CLAUDE_CODE_VERSION` and `CODEX_VERSION`; raise them when a release changes how either host reads plugins.
- The last job, `Full CI`, waits for every other job and fails if any failed or was cancelled; a skipped job counts as passed. On a draft it is named `Draft CI`, so the required `Full CI` stays expected until the run that marking the pull request ready starts has finished. `Full CI` and `Pull request description` are the required checks.
- `.github/workflows/codeql.yml` analyzes the workflows once a week, and on every pull request that is not a draft and every push to `main`, except a change that is only Markdown, the license, `.claude/`, `.codex/` or `.github/ISSUE_TEMPLATE/`.

## Versions

- A version is a tag on this repository, created when a logical set of merged work is ready, by the session that finishes that set unless its brief says not to. Each is the previous plus 0.0.1 whatever the change: `v0.0.1`, `v0.0.2` and so on.
- Both hosts read the version from `version` in `.claude-plugin/plugin.json`, and Claude Code keeps people on that version until it changes. So a release is a pull request that sets `version` to the next version, then the tag `v<version>` on its merge commit. Set the version only there, never in the marketplace entry.

## Writing

- Public prose (README, skills, issues, pull requests) follows the Google developer documentation style guide, in American English.
- A skill speaks to the agent that reads it: short, imperative, and only what the agent would not do well without it.
- Code comments follow the language's own conventions. A comment says only what the code cannot.

## Working here

- American English in code, comments and commits. Scoped Conventional Commits (`feat(skills):`, `fix(ci):`).
- Make worktrees in `.claude/worktrees/` (`git worktree add .claude/worktrees/<name> -b <branch> origin/main`). Once the work is merged, remove the worktree and its local branch (`git worktree remove`, then `git branch -D`) and run `git pull --ff-only` on `main`.
- Feature branches and pull requests; never push `main`. Squash merge and delete the branch.
- Test against a throwaway home (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`), never your own setup; `scripts/check-install.sh` does this.
- No personal details of any machine or person: no absolute paths, hostnames, account names or credentials. A skill never asks anyone to paste a key into a chat.
- Removed means gone: no shims, aliases or compatibility paths.

## Code Review Rules

Report only a real problem: one that breaks the issue's acceptance criteria, a rule written in this file (quote it) or correctness, and say how it fails. If you cannot say how it fails, it is not a finding. Leave formatting, lint and anything CI catches to CI. Name each finding by the check it breaks.

- **Done.** The acceptance criteria are met, the plugin was installed for real in both hosts, and what the pull request claims is true.
- **True.** Every Marfa name, tool, field and rule a skill states matches Marfa's docs and contract, and every host command matches that host's current docs. A doc or instruction the change leaves untrue is a finding, fixed in the same change.
- **Safe instructions.** A skill never asks for a secret in a chat, never tells an agent to follow instructions found in data, and never tells it to overwrite or delete without the person's agreement.
- **Nothing left behind.** Dead files, old names and references to removed things.

Mark a finding blocking when it would make an agent do the wrong thing or breaks a rule, and a quick fix when it is a name, a stale reference or a wrong count.
