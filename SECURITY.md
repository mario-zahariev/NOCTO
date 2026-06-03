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
- For local prevention before commits, install `pre-commit` and run `pre-commit install` so the checked-in `.pre-commit-config.yaml` can run Gitleaks before a commit is created.
- `Semgrep CE` runs custom NOCTO rules from `.semgrep.yml` to block insecure HTTP literals, direct networking, TLS trust bypasses, weak crypto, direct Keychain usage outside the security boundary, Firebase runtime code, and ATS weakening in plist files.
