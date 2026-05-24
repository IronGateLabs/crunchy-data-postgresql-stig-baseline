# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Chef InSpec compliance profile that audits a Crunchy Data PostgreSQL installation against the DISA STIG (Security Technical Implementation Guide). It is **not** an application — it is a collection of declarative test controls. A run connects to a target database/host, evaluates each STIG requirement, and emits pass/fail results used to support an Authority to Operate (ATO) decision. Applies to PostgreSQL versions 10–15.

- Profile version `3.1.0`, STIG benchmark V3R1 (24 Jul 2024).
- The `main` branch is a development branch for the *next* release; tagged/released versions are what get used for formal A&A testing.

## Architecture

- **`controls/V-2335XX.rb`** — one file per STIG control (~113 controls). Each is a `control '<id>' do … end` block declaring `title`, `desc`, `desc 'check'`, `desc 'fix'`, `impact`, compliance `tag`s (gtitle/gid/rid/stig_id/cci/nist), and one or more `describe` blocks holding the actual assertions. The control ID (e.g. `V-233515`) is the filename, the `control` name, and the `gid` tag — keep all three in sync.
- **`libraries/postgres_session.rb`** — custom InSpec resource. Overrides the upstream `postgres_session` to run queries via `psql -d postgresql://user:pass@host:port/db`, redacting the password from logs. ~77 controls query the DB through this resource; it returns a `Lines` object whose `.output` / `.lines` you assert against. Controls that don't need SQL use built-in resources like `postgres_hba_conf`, `postgres_conf`, `file`, `command`.
- **`inspec.yml`** — profile metadata **and** the canonical definition of every `input` (variable) with its default. Inputs parameterize controls for a specific environment (paths, ports, superuser lists, approved auth methods, etc.). Many input descriptions list the exact `V-2335XX` controls that consume them.
- **`inputs_postgres12_example.yml` / `inputs_postgres14_example.yml`** — example override files passed via `--input-file` at run time.
- **`progress.md`** — manual tracking table mapping each control to a verification status and its legacy 9.x control number.

### Inputs are the customization seam

Do **not** edit default values in `inspec.yml` to fit an environment, and do not hardcode environment-specific values inside controls. Controls reference values with `input('pg_hba_conf_file')`, `input('pg_port')`, etc. Environment-specific values are supplied at run time via `--input-file=<file>.yml` or `--input <name>=<value>`. When adding a control that needs a new tunable, add it as an input in `inspec.yml` with a sensible default rather than embedding a literal.

## Commands

This is a Ruby/Bundler project driven by `inspec` (or the open-source `cinc-auditor` binary — the two are interchangeable in every command below).

```bash
bundle install                          # install Ruby dependencies (Gemfile)
```

Linting / validation (run before committing — these are the project's gate):
```bash
bundle exec rake inspec:check           # validate the InSpec profile (or cinc-auditor:check)
bundle exec rake lint                   # RuboCop
bundle exec rake lint:auto_correct      # RuboCop safe autocorrect
bundle exec rake test                   # minitest unit tests (libraries/) + SimpleCov coverage
bundle exec rake pre_commit_checks      # full pre-commit gate (lint + test + check)
```

Run the profile against a target:
```bash
# local test DB (see below)
inspec exec ./ --input-file ./inputs_postgres14_example.yml --reporter cli json:./results/file.json

# remote host over ssh
bundle exec inspec exec . --input-file=<inputs>.yml -t ssh://<host>:<port> --sudo --reporter=cli json:<out>.json
```

Run / debug a single control:
```bash
inspec exec ./ --input-file ./inputs_postgres14_example.yml --controls V-233515 --reporter cli
```

### Local test database

`docker-compose.yml` starts a throwaway PostgreSQL 14 container (`testuser`/`testpassword`, db `testdb`) seeded by `init.sql`. Requires Docker, `psql`, and InSpec/cinc-auditor on the runner.
```bash
docker compose up -d
inspec exec ./ --input-file ./inputs_postgres14_example.yml --reporter cli json:./results/file.json
```
Note: `init.sql` and the example input files are convenience fixtures for local testing — they are not the audited configuration.

## Conventions

- Ruby 3.1.2 is the tested interpreter; newer Ruby is not guaranteed to behave identically.
- The `Gemfile` pins **InSpec 5** on purpose: InSpec 6+ refuses to run without a commercial Chef license key (exit 174, "cannot execute without valid licenses"). Do not bump to 6/7 without wiring a license key or switching to `cinc-auditor`. v5 satisfies `inspec.yml` (needs only `>= 4.0`).
- Unit tests live in `test/` and only cover `libraries/` (the custom resource); the controls are declarative and are validated by *running* the profile against a DB, not by line-coverage tests. Coverage (Codecov) therefore reflects `libraries/` only.
- When editing a control, preserve the STIG `tag` metadata exactly — those CCI/NIST/rid identifiers are the traceability link to the official benchmark and must not be invented or altered to make a test pass.
- Results are viewed in [Heimdall](https://heimdall-lite.mitre.org/); the JSON reporter output is the artifact that flows downstream to stakeholders, so the profile/guidance name and control IDs must stay stable.
