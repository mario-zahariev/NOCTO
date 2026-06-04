# Security Policy

## Supported Branch

Only the `main` branch is supported for security updates.

## Reporting a Vulnerability

- Open a private security report by emailing: `security@nocto.app`
- Include reproduction steps, impact assessment, and affected commit/branch.
- Do not publish exploit details before coordinated remediation.

## Secrets Handling

- Never commit real API keys, tokens, or Firebase production plist files.
- Use placeholders and local-only config files for development.
- `Gitleaks` runs in CI with the NOCTO-specific `.gitleaks.toml` ruleset.
- The ruleset extends the default Gitleaks rules and additionally blocks NOCTO token prefixes, Google API keys, Apple private-key material, signing/provisioning files, and local-only config filenames.
- CI secret scanning fails the workflow and should be required before merging pull requests. It does not remove a secret that was already pushed; rotate exposed credentials immediately and clean history when needed.
- For local prevention before commits, install `pre-commit` and run `pre-commit install` so the checked-in `.pre-commit-config.yaml` can run Gitleaks and Semgrep before a commit is created.
- `Semgrep CE` runs custom NOCTO rules from `.semgrep.yml` to block insecure HTTP literals, direct networking, TLS trust bypasses, weak crypto, direct Keychain usage outside the security boundary, Firebase runtime code, and ATS weakening in plist files.

## Protected Branch Contract

The `main` branch must stay protected in GitHub.

Required enforcement:

- required status checks with strict branch currency;
- `swift-package-tests`;
- `iOS-build-smoke`;
- `Gitleaks full-history scan`;
- `semgrep-oss/scan`;
- pull request review before merge;
- Code Owner review before merge;
- stale review dismissal after new commits;
- last-push approval;
- signed commits on `main`;
- linear history;
- conversation resolution before merge;
- force pushes disabled;
- branch deletion disabled;
- admin enforcement enabled.

The CI security contract also guards that key security files, pinned GitHub Actions, Firebase detachment checks, Swift tests, and visual integrity gates are not silently removed.
