## ADDED Requirements

### Requirement: The custom resource has unit tests
The `libraries/postgres_session.rb` resource SHALL have unit tests covering its pure logic — the `Lines` wrapper and the psql command construction (including password redaction and shell escaping) — runnable via a rake task without a live database.

#### Scenario: Resource unit tests run offline
- **WHEN** a contributor runs the unit-test rake task
- **THEN** the `postgres_session` tests execute without connecting to PostgreSQL
- **AND** the task exits non-zero if any assertion fails

#### Scenario: Command construction is asserted
- **WHEN** the psql command is built for a query
- **THEN** the test asserts the connection URI, flags, and escaping are correct for the unix and windows branches

### Requirement: Coverage is measured and reported
SimpleCov SHALL be wired so that running the unit tests (and/or the profile) produces a coverage report in a CI-consumable format (e.g. lcov/cobertura) under a coverage output directory.

#### Scenario: Coverage report is generated
- **WHEN** the unit tests run with coverage enabled
- **THEN** a coverage report file is written to the coverage output directory

### Requirement: Coverage is uploaded to Codecov
CI SHALL upload the generated coverage report to Codecov on pull requests and pushes to the default branch, authenticated with the `CODECOV_TOKEN` secret.

#### Scenario: Coverage uploaded on a pull request
- **WHEN** the CI workflow completes the test step on a pull request
- **THEN** the coverage report is uploaded to Codecov
