## Why

The `quality-foundation` change unit-tests the `postgres_session` resource and runs the profile against a single docker database, but nothing verifies that the 113 controls produce the *correct* result — that a compliant config makes a control **pass** and a non-compliant config makes it **fail**. Without that, a control can silently rot into always-passing (a false sense of compliance) and no test would catch it. This change adds behavioral/integration tests that assert control outcomes against known database states.

## What Changes

- Provision PostgreSQL in controlled states and run the profile against each:
  - a **vanilla** (unhardened) state — expected to fail the controls it should fail;
  - a **hardened** (STIG-compliant) state — expected to pass.
- Assert expected results with **MITRE SAF threshold files** (`saf validate threshold`), the idiomatic way to gate an InSpec profile's results, rather than hand-parsing JSON.
- Add the fixtures that drive each state (SQL seed + `postgresql.conf`/`pg_hba.conf` overrides applied to the container).
- Add a CI workflow (or extend `validate.yml`) that runs the state matrix and fails on threshold violations.
- Phase the coverage: start with a representative, high-signal subset of controls and a captured baseline (regression guard), then widen toward full hardened coverage.

### Out of scope
- Hardening every one of the 113 controls to full pass in the first pass — that is the phased follow-on, not the initial deliverable.
- Changing any control logic or the profile's behavior.

## Capabilities

### New Capabilities
- `control-integration-tests`: Behavioral tests that seed PostgreSQL into known-good/known-bad states and assert expected per-control pass/fail via SAF threshold files, wired into CI.

### Modified Capabilities
None.

## Impact

- Depends on `quality-foundation` (docker-compose DB, bundled InSpec 5, CI scaffolding) — should land after it.
- New dev dependency: `saf` CLI (or the `mitre/saf_action` GitHub Action) for threshold validation.
- New files: state fixtures (SQL + config), `*.threshold.yml` files, a CI workflow; a `test/integration/` (or `spec/`) layout for the harness.
- Does not affect Codecov line coverage (these are profile-execution tests, not Ruby unit tests) — it raises *control-level* confidence, complementing `progress.md`.
