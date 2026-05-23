## ADDED Requirements

### Requirement: Documented rake tasks are runnable
The repository SHALL provide a `Gemfile` and `Rakefile` such that the lint and validation commands named in the README work as documented. The Rakefile MUST define `lint` (RuboCop), `inspec:check`, and `pre_commit_checks`, and `lint:auto_correct` MUST be available via the RuboCop rake task.

#### Scenario: Lint task runs RuboCop
- **WHEN** a contributor runs `bundle exec rake lint`
- **THEN** RuboCop runs over the profile's Ruby files
- **AND** the command exits non-zero if any offense is reported

#### Scenario: Check task validates the profile
- **WHEN** a contributor runs `bundle exec rake inspec:check`
- **THEN** `inspec check` validates the profile structure
- **AND** the command exits non-zero if the profile is invalid

#### Scenario: Pre-commit task runs both gates
- **WHEN** a contributor runs `bundle exec rake pre_commit_checks`
- **THEN** both `lint` and `inspec:check` run
- **AND** the command exits non-zero if either fails

### Requirement: Dependencies are minimal and pinned to the tested toolchain
The `Gemfile` SHALL list only the gems this profile actually uses (InSpec/cinc-auditor, RuboCop and its rake integration, Rake), and the Ruby version SHALL be recorded so contributors and CI use the toolchain the README documents (Ruby 3.1.x). Gems specific to unrelated test harnesses (e.g. Test Kitchen, cloud/EC2 drivers) MUST NOT be included.

#### Scenario: Bundle installs on the supported Ruby
- **WHEN** `bundle install` is run on Ruby 3.1.x
- **THEN** all declared dependencies resolve and install without error

### Requirement: RuboCop is configured for an InSpec profile
A `.rubocop.yml` SHALL be present and tuned so RuboCop evaluates the profile without flagging the InSpec control DSL as style violations.

#### Scenario: RuboCop runs against the controls
- **WHEN** `bundle exec rake lint` runs against `controls/` and `libraries/`
- **THEN** RuboCop applies the project configuration rather than unconfigured defaults
