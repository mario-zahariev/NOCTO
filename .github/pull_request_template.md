## Summary

-

## Changes

-

## Test Plan

- [ ] `swift test`
- [ ] Local app smoke build
- [ ] `pre-commit run --all-files`
- [ ] `bash scripts/ci/check_security_contract.sh`
- [ ] `bash scripts/ci/check_github_actions_pinned.sh`
- [ ] UI/snapshot check if UI changed

## Risk (select one)

Select one:

- [ ] Low
- [ ] Medium
- [ ] High

## Security / Architecture

- [ ] No secrets, tokens, signing material, or local config files added
- [ ] No Firebase runtime code added
- [ ] No direct networking, Keychain, weak crypto, or ATS weakening outside approved boundaries
- [ ] No unpinned GitHub Actions or mutable container images added
- [ ] `Package.resolved` remains tracked

## UI / Snapshot Scope

- [ ] Snapshot baseline changes are intentional
- [ ] Manual device QA needed and documented when gestures, map, navigation, or safe area behavior changed
