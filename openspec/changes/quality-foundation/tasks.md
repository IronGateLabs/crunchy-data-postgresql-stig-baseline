## 1. Build scaffolding

- [x] 1.1 Add `Gemfile` with the minimal dependency set (`inspec`, `inspec-bin`, `rake`, `rubocop`, `rubocop-rake`, `minitest`, `simplecov`, `pry-byebug`); no kitchen/cloud gems
- [x] 1.2 Add `Rakefile` defining `inspec:check`, `lint` (via `RuboCop::RakeTask`, which provides `lint:auto_correct`), `test`, and `pre_commit_checks: [:lint, :test, 'inspec:check']`
- [x] 1.3 Add `.ruby-version` pinned to 3.1.2
- [x] 1.4 Add `.rubocop.yml` tuned for the InSpec control DSL (Naming/FileName + idiomatic-matcher cops disabled, metrics relaxed)
- [~] 1.5 Run `bundle install` and commit the resulting `Gemfile.lock` (bundle install verifying in background)

## 2. Verify the documented commands work

- [~] 2.1 Confirm `bundle exec rake inspec:check` validates the profile (verifying in background)
- [x] 2.2 Confirm `bundle exec rake lint` runs RuboCop — baseline now 0 offenses across 117 files
- [~] 2.3 Confirm `bundle exec rake pre_commit_checks` runs all gates (lint + test verified; inspec:check pending bundle)
- [x] 2.4 Lint blocking decision: green + blocking, achieved via safe autocorrect (`rubocop -a`) of cosmetic offenses, isolated for a dedicated commit

## 3. CI: lint & check

- [x] 3.1 Add `.github/workflows/lint.yml` (push to main + PR) running setup-ruby 3.1, bundle, `rake inspec:check`, `rake lint`, `CHEF_LICENSE: accept-silent`
- [x] 3.2 Stripped the SAF reference's kitchen/EC2 env vars and secrets that don't apply

## 4. CI: profile run against the test DB

- [x] 4.1 Add `.github/workflows/validate.yml` (PR + push) bringing up `docker-compose.yml` (Postgres 14) with a `pg_isready` wait loop
- [x] 4.2 Run `inspec exec . --input-file inputs_postgres14_example.yml` with cli + json reporters
- [x] 4.3 `--no-distinct-exit` so the job fails only on parse/execution errors, not control findings

## 5. Unit tests & coverage

- [x] 5.1 Added `minitest`, `simplecov`, `simplecov-lcov` to the Gemfile
- [x] 5.2 `test/test_helper.rb` starts SimpleCov (lcov → `coverage/lcov.info`) before loading `libraries/`
- [x] 5.3 `test/libraries/postgres_session_test.rb` covers `Lines` and psql command construction (escaping/redaction, unix + windows) — 6 tests, 14 assertions, 82.86% line coverage
- [x] 5.4 `test` rake task folded into `pre_commit_checks`; tests pass and `coverage/` is produced
- [x] 5.5 Added `codecov.yml` and a Codecov upload step (`codecov/codecov-action@v4`, `CODECOV_TOKEN`) to `quality.yml`

## 6. SonarCloud

- [x] 6.1 Added `sonar-project.properties` (org/project keys, `sonar.sources=controls,libraries`, `sonar.ruby.coverage.reportPaths` → lcov)
- [x] 6.2 Added SonarCloud scan to `quality.yml` (PR + push) using `SONAR_TOKEN`, after lint/test
- [x] 6.3 Sonar/Codecov steps gated on their secrets being present so CI isn't hard-red before account setup

## 7. Wrap-up

- [ ] 7.1 Document required repo secrets (`SONAR_TOKEN`, `CODECOV_TOKEN`) and SonarCloud org setup for the fork owner
- [ ] 7.2 Verify all workflows run green (or expected-red per 6.3) on a test PR against the fork
- [ ] 7.3 Reconcile the README's quality-workflow section with what now exists (add unit-test/coverage commands)
