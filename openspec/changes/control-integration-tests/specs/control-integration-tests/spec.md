## ADDED Requirements

### Requirement: Reproducible non-compliant database state
The harness SHALL provision a baseline ("vanilla") PostgreSQL with no STIG hardening, wired so the profile's queries actually connect (matching role/database for the example inputs), and run the profile against it producing a machine-readable result.

#### Scenario: Vanilla state produces connectable results
- **WHEN** the vanilla state is provisioned and the profile is run against it
- **THEN** a JSON result file is produced
- **AND** control results reflect configuration findings, not psql connection failures

### Requirement: Reproducible compliant database state
The harness SHALL provision a "hardened" PostgreSQL state that applies the STIG-relevant configuration (e.g. `postgresql.conf`/`pg_hba.conf` settings and seed SQL) so that the controls targeted by that state report **pass**.

#### Scenario: Hardened state passes its targeted controls
- **WHEN** the hardened state is provisioned and the profile is run against it
- **THEN** the controls in that state's target set report `passed`

### Requirement: Expected outcomes are asserted via SAF threshold files
Each state SHALL have a `*.threshold.yml` file capturing its expected results, and CI SHALL gate the run with `saf validate threshold`, failing when actual results deviate from the threshold.

#### Scenario: A regression flips a control and fails the threshold
- **WHEN** a change causes a control that should pass to fail (or vice versa)
- **THEN** `saf validate threshold` exits non-zero and the job fails

#### Scenario: Expected results satisfy the threshold
- **WHEN** the profile run matches the recorded threshold for a state
- **THEN** `saf validate threshold` passes

### Requirement: CI runs the state matrix
A GitHub Actions workflow SHALL run the integration tests for each defined state on pull requests and on pushes to the default branch, failing on any threshold violation.

#### Scenario: Pull request runs the matrix
- **WHEN** a pull request is opened or updated
- **THEN** the workflow runs each state and reports threshold pass/fail for each
