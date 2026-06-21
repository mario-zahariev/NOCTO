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

## Product and Design System

- Treat `docs/PRODUCT_BIBLE.md` as the brand/product canon for public UI, copy,
  visual direction, motion, components, and Sofia-specific signals.
- Treat `docs/ARCHITECTURE.md` as the living technical architecture document.
- Keep public UI labels in Bulgarian unless a technical or brand term requires
  otherwise.

## Pull Requests

- Include problem statement and test notes.
- Add screenshots for UI changes.
- Ensure CI is green before merge.
- Expect CODEOWNERS to request `@mario-zahariev` review for code, CI,
  package, data, script, and test changes.
- Do not force-merge or use admin override for normal work.

## Implementation Guardrails

Every PR should answer:

- Which product decision does it support?
- Which surface does it change?
- Does it preserve local-first architecture?
- Does it preserve Firebase detachment?
- Does it improve signal quality, clarity, or polish?
- Does the UI become clearer, quieter, or more useful?

Avoid:

- random rebuilds
- new abstractions without payoff
- decorative UI without signal
- unverified asset churn
- generated archives in git
- accidental Firebase re-attachment
- turning `Админ` into consumer UX

## UI PR Acceptance Checklist

Before merge:

- JSON validator passes
- Firebase detachment guard passes
- Swift tests pass
- simulator build passes if the change touches app UI
- public UI labels are in Bulgarian
- no black-on-black unreadable text
- no clipped Bulgarian labels
- no public Admin regression without an explicit decision
- no unreviewed `.xcodeproj` churn
- no real secrets or production plists

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

## Documentation and Coverage

The `Docs and Coverage` workflow can generate:

- a Swift coverage JSON artifact for the package tests
- a DocC archive artifact for `NOCTOCore`

It runs automatically when package sources, tests, `Package.swift`, or the
workflow itself change, and can also be started manually from GitHub Actions.
