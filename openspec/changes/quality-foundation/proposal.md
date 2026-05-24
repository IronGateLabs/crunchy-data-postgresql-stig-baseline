## Why

The README documents a quality workflow (`bundle exec rake lint`, `inspec:check`, `pre_commit_checks`) and a Gemfile, but none of that scaffolding exists in the repo — the commands fail and there is no CI, so nothing enforces that controls lint or that the profile even parses. This phase restores the missing foundation so later quality work (SonarCloud, coverage, upstream-sync) has something to build on.

## What Changes

- Add the Ruby/Bundler scaffolding the README already assumes: `Gemfile`, `Rakefile`, `.rubocop.yml`, `.ruby-version`, pinned to the MITRE SAF profile conventions so `bundle exec rake lint` / `inspec:check` / `pre_commit_checks` work as documented.
- Add a GitHub Actions workflow that runs RuboCop and `inspec check` on every push/PR, and runs the profile against the `docker-compose` test database to catch parse/runtime breakage.
- Add unit tests (minitest) for the custom `libraries/postgres_session.rb` resource and wire SimpleCov so the profile produces a coverage report.
- Upload coverage to **Codecov** and run **SonarCloud** static analysis on pull requests, with the RuboCop and coverage outputs fed into Sonar.
- No control logic, inputs, or profile behavior changes.

### Out of scope (later phases)
Fork-vs-upstream / fork-vs-latest-STIG reconciliation is deferred to its own change.

> Note on coverage scope: meaningful line coverage on an InSpec profile is limited to the custom Ruby in `libraries/` — the declarative controls are not "covered" in the SimpleCov sense. Codecov here measures the resource code plus whatever the profile run exercises; it is not a profile-completeness metric (that remains `progress.md`'s job).

## Capabilities

### New Capabilities
- `build-scaffolding`: The Bundler/Rake/RuboCop project files that make the documented lint and validation commands runnable, matching MITRE SAF profile conventions.
- `ci-pipeline`: Automated checks (RuboCop, `inspec check`, profile run against the test DB) that gate pushes and pull requests on the fork.
- `unit-test-coverage`: Minitest unit tests for the `postgres_session` resource plus SimpleCov coverage reporting, uploaded to Codecov from CI.
- `static-analysis`: SonarCloud scanning on pull requests, consuming RuboCop and coverage output.

### Modified Capabilities
None — no existing spec requirements change.

## Impact

- New root files: `Gemfile`, `Rakefile`, `.rubocop.yml`, `.ruby-version`, `sonar-project.properties`, `codecov.yml`; new `.github/workflows/`; new `test/` (or `spec/`) directory for unit tests.
- A `Gemfile.lock` will be generated and committed (standard for a deployable profile).
- New CI secrets required on the fork: `SONAR_TOKEN`, `CODECOV_TOKEN`.
- Affects contributor workflow and CI only; the audited profile content and its results are unchanged.
- Tooling versions follow the README's tested baseline (Ruby 3.1.2, `inspec`/`cinc-auditor`).
