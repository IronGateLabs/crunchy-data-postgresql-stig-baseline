## ADDED Requirements

### Requirement: Pushes and pull requests are linted and validated
A GitHub Actions workflow SHALL run `bundle exec rake lint` and `bundle exec rake inspec:check` on pushes to the default branch and on pull requests, and SHALL fail the check when RuboCop reports offenses or the profile fails validation.

#### Scenario: PR with a lint offense fails
- **WHEN** a pull request introduces a RuboCop offense
- **THEN** the workflow runs and the lint step fails the check

#### Scenario: PR with an invalid profile fails
- **WHEN** a pull request makes the profile fail `inspec check`
- **THEN** the workflow runs and the check step fails

### Requirement: The profile is executed against a live database in CI
A GitHub Actions workflow SHALL stand up the project's docker-compose PostgreSQL test database and run the profile against it using the committed example input file, failing the job on profile execution errors.

#### Scenario: Profile runs against the test database
- **WHEN** the workflow triggers on a pull request
- **THEN** the PostgreSQL test container is started
- **AND** the profile is executed against it with the example input file
- **AND** the job fails if the profile cannot execute (parse or runtime error)
