# Changelog

All notable changes to this repository will be documented in this file.

## [Unreleased]

## [2026-04-04] - Delivery baseline and docs hardening
### Added
- Added delivery-focused documents:
  - `ACCEPTANCE_MAPPING.md`
  - `THIRD_PARTY.md`
  - `DATASETS.md`
  - `CHANGELOG.md`
  - `FINAL_HANDOFF.md`
- Added minimal validation entry script:
  - `scripts/run_minimal_validation.sh`

### Changed
- Unified delivery wording to "最小验证" in user-facing docs.
- Updated acceptance mapping with:
  - original acceptance text preserved where required,
  - current implementation status based on repository evidence,
  - evidence/command/output mapping.
- Set official GitHub repository URL to:
  - `https://github.com/Mongodiem/HWME`

### Notes
- Current runnable backend in this repository is `vllm`.
- Data/model artifacts are external dependencies and are not distributed in-repo.
