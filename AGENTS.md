# Repository Guidelines

## Project Structure & Module Organization
- `ansible/pull_all_repos.yml` is the main playbook that discovers repos, selects branches, and pulls.
- `ansible/scripts/select_branch.sh` contains the branch selection and checkout logic.
- `config.pull.json` is the default configuration for base directories, branch priority, and safety flags.
- `package.json` defines convenience scripts for running the playbook with Bun.
- `README*.md` documents behavior, configuration, and usage details.

## Build, Test, and Development Commands
- `bun run git:pull`: run the playbook against configured repos with defaults.
- `bun run git:pull:dry`: dry-run mode; prints planned actions without pulls.
- `bun run git:pull:all`: include dirty repos by setting `skip_dirty=false`.
- `ansible-playbook -i localhost, -c local ansible/pull_all_repos.yml`: direct playbook run.
- `PULL_CONFIG=/path/to/config.pull.json ansible-playbook -i localhost, -c local ansible/pull_all_repos.yml`: run with a custom config.

## Coding Style & Naming Conventions
- YAML and JSON use 2-space indentation (match `ansible/pull_all_repos.yml` and `config.pull.json`).
- Ansible variables are `snake_case` (e.g., `skip_dirty`, `branch_priority`).
- Shell script variables are uppercase for env inputs and lowercase for locals.
- Keep changes minimal and explicit; prefer readable, linear Ansible tasks.

## Testing Guidelines
- No automated tests are defined for this repository.
- Use `bun run git:pull:dry` before running a real pull to validate branch selection and scope.
- When changing branch logic, test against a small `base_dirs` set first.

## Commit & Pull Request Guidelines
- Existing commits use short, lowercase messages (e.g., "some fixes"). Follow that style unless a stricter convention is agreed.
- For PRs, include a brief summary, the commands run (e.g., `bun run git:pull:dry`), and any config changes.

## Security & Configuration Tips
- Review `base_dirs` and `exclude_dirs` in `config.pull.json` before running against new locations.
- Prefer `skip_dirty=true` and `pull_ff_only=true` to avoid unintended merges.
