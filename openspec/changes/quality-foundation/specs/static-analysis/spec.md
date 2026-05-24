## ADDED Requirements

### Requirement: SonarCloud scans the repository on pull requests
A GitHub Actions workflow SHALL run a SonarCloud scan on pull requests and pushes to the default branch, configured via `sonar-project.properties` and authenticated with the `SONAR_TOKEN` secret.

#### Scenario: Scan runs on a pull request
- **WHEN** a pull request is opened or updated
- **THEN** the SonarCloud workflow runs and reports analysis back to the PR

### Requirement: SonarCloud ingests lint and coverage results
The SonarCloud configuration SHALL point at the Ruby sources (`controls/`, `libraries/`) and consume the RuboCop and SimpleCov coverage outputs so findings and coverage appear in the Sonar project rather than being recomputed.

#### Scenario: Coverage and lint surfaced in Sonar
- **WHEN** the scan runs after the test/lint steps
- **THEN** SonarCloud reflects the coverage report and RuboCop findings for the analyzed sources
