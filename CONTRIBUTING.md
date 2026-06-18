# Contributing

## Branching

- Use short-lived feature branches from `main`.
- Keep pull requests focused and small.
- Use the `NOCTO/` branch prefix for project work when practical.

## Commit Style

- Use clear imperative messages.
- Include context when touching data contracts or security-sensitive files.

## Code Standards

- Swift 5 style with clear naming and small composable views.
- Handle errors explicitly; avoid force unwraps and force-try.
- Validate external input before rendering.

## Pull Requests

- Include problem statement and test notes.
- Add screenshots for UI changes.
- Ensure CI is green before merge.
- Expect CODEOWNERS to request `@mario-zahariev` review for all PRs.
- Do not force-merge or use admin override for normal work.

## Workflow Labels

Use GitHub Projects plus labels to keep issue state visible:

- `status:todo` means planned work that has not started.
- `status:in-progress` means active work.
- `status:done` means completed work.

When starting work, assign yourself and replace `status:todo` with
`status:in-progress`. When the work is merged or otherwise complete, replace it
with `status:done`.

## Project Board Automation

The Audit Roadmap project should mirror the status labels. Configure built-in
GitHub Project automations with these rules:

- When label `status:todo` is added, move the item to `Backlog` or `Todo`.
- When label `status:in-progress` is added, move the item to `In progress`.
- When label `status:done` is added, move the item to `Done`.

Prefer GitHub's built-in project automation for board movement instead of
granting broad write access to external bots.

## Required Checks

Before merge, branch protection requires the repository checks to pass,
including:

- `Architecture Guard & Unit Tests`
- `Gitleaks full-history scan`
- `semgrep-oss/scan`
- `iOS-build-smoke`
- CodeQL and security/trust checks

If a PR appears green but cannot merge, compare the PR checks with the required
contexts configured for `main` branch protection.
