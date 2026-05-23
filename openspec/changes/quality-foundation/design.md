## Context

The README documents a Bundler/Rake quality workflow, but the `Gemfile`, `Rakefile`, `.rubocop.yml`, and CI never existed in this repo or its `upstream` (mitre). The README's task names (`inspec:check`, `lint`, `lint:auto_correct`, `pre_commit_checks`) are verbatim from the MITRE SAF InSpec-profile template, so the canonical implementations already exist in sibling SAF baselines — e.g. `mitre/redhat-enterprise-linux-9-stig-baseline`, whose Rakefile defines exactly those tasks. The constraint is to match SAF conventions (what auditors and contributors expect) without importing machinery this profile doesn't use.

## Goals / Non-Goals

**Goals:**
- Make the README's documented commands actually run.
- Gate pushes/PRs on RuboCop + `inspec check`, and on the profile executing against a real PostgreSQL.
- Stay idiomatic to MITRE SAF profiles.

**Non-Goals:**
- No fork-vs-upstream / fork-vs-latest-STIG reconciliation (later change).
- No Test Kitchen / EC2 / IronBank / Heimdall-upload CI — that machinery in the reference baselines targets OS hardening pipelines, not a DB profile tested via `psql`/docker-compose.
- No changes to controls, inputs, or profile behavior.

## Decisions

- **Source from the SAF template, then trim.** Adopt the reference `Rakefile` essentially as-is (it already defines `inspec:check`, `lint` via `RuboCop::RakeTask` — which auto-provides `lint:auto_correct` — and `pre_commit_checks`). *Alternative rejected:* hand-writing our own task names would diverge from the README and the ecosystem.
- **Minimal Gemfile.** Include only `inspec`/`inspec-bin`, `rubocop`, `rubocop-rake`, `rake` (plus `pry-byebug` for local debugging). *Alternative rejected:* copying the reference Gemfile wholesale pulls `test-kitchen`, `kitchen-*`, `train-awsssm`, etc. — unused here and exactly the bloat we're avoiding.
- **Two workflows, not one.** `lint.yml` (lint + check, on push to default branch and PRs) modeled directly on the reference `lint-profile.yml` but stripped of the kitchen env vars. `validate.yml` (run profile against the DB, on PRs) implemented natively: start the existing `docker-compose.yml` Postgres 14 fixture and run `inspec exec . --input-file inputs_postgres14_example.yml`. *Alternative considered:* a GitHub Actions `services:` postgres container — rejected in favor of reusing the repo's own compose fixture so CI exercises the same path a developer does.
- **Ruby 3.1 / `.ruby-version`.** Pin to the README's tested interpreter; `ruby/setup-ruby@v1` with `ruby-version: "3.1"` in CI.
- **`CHEF_LICENSE: accept-silent`** in CI so InSpec runs unattended. No Chef license *key* secret is needed for `inspec check`/`exec`.
- **Commit `Gemfile.lock`.** Reproducible installs; standard for a deployable profile.
- **Unit tests target the resource's pure logic via minitest.** Test the `Lines` class and psql command construction (URI, flags, `Shellwords` escaping, password redaction, unix vs windows branch). The resource subclasses `Inspec.resource(1)` and shells out via `inspec.command`, so tests exercise the command-building seam, not a live psql. *Alternative rejected:* a full InSpec resource integration test against a live DB — that's what the `validate` workflow already does; duplicating it as a "unit" test is slop.
- **Coverage via SimpleCov with an lcov formatter.** A `.simplecov`/test-helper starts SimpleCov before loading `libraries/`; `simplecov-lcov` (or cobertura) emits a CI-consumable report under `coverage/`. *Honesty constraint:* coverage reflects `libraries/` Ruby exercised by the unit tests, not the declarative controls — documented in the proposal so no one reads the number as profile completeness.
- **Codecov via `codecov/codecov-action@v4`** with `CODECOV_TOKEN`, uploading `coverage/` output on PRs and default-branch pushes.
- **SonarCloud via `SonarSource/sonarqube-scan-action`** (SonarCloud flavor) with `SONAR_TOKEN` and a `sonar-project.properties` that sets the org/project keys, `sonar.sources=controls,libraries`, and points `sonar.ruby.coverage.reportPaths` at the SimpleCov lcov output. Run after lint+test so Sonar ingests rather than recomputes. *Alternative considered:* self-hosted SonarQube — rejected; SonarCloud is the zero-infra path for a fork.

## Risks / Trade-offs

- **RuboCop floods the InSpec DSL with offenses** → ship a `.rubocop.yml` tuned for control files (long `desc` strings, block lengths); start lenient and tighten later rather than mass-editing controls now.
- **`inspec exec` exits non-zero on control failures, not just errors** → the `validate.yml` job must distinguish "profile failed to run" (real CI failure) from "controls reported failures against the throwaway DB" (expected). Run with a reporter and treat only execution/parse errors as job failure.
- **Docker-compose port 5432 / readiness races** → wait for DB readiness (healthcheck or `pg_isready` poll) before running the profile.

## Open Questions

- Confirm `inspec` vs `cinc-auditor` in CI — `inspec` gem in the Gemfile is simplest; cinc is the README's runtime recommendation but adds install steps. Leaning `inspec` gem for CI, both supported locally.
- Should `lint` initially be non-blocking (report-only) until the existing controls are brought into compliance, then flipped to blocking? Affects whether the first CI run is red.
- SonarCloud and Codecov require account setup (Sonar org/project keys, both tokens added as repo secrets) that only the fork owner can do. CI for these will be red until those secrets exist — acceptable, or gate them behind `if: secrets present`?
