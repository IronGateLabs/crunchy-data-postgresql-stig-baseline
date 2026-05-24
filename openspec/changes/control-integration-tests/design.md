## Context

`quality-foundation` added a `validate` workflow that proves the profile *executes* against the docker-compose PostgreSQL, but it is only a smoke test — control pass/fail is ignored. The first run also exposed that many controls report failures because their psql queries default the database name to the username (`database "testuser" does not exist`), i.e. results currently reflect connection/wiring rather than configuration. This change makes control outcomes meaningful and regression-guarded.

The idiomatic MITRE SAF approach (used by sibling baselines) is to run the profile against known states and gate the JSON results with `saf validate threshold` against committed `*.threshold.yml` files.

## Goals / Non-Goals

**Goals:**
- Provision PostgreSQL in known vanilla and hardened states with the profile actually connecting.
- Assert per-state expected results via SAF threshold files, run in CI.
- Catch regressions where a control silently flips pass/fail.

**Non-Goals:**
- Hardening all 113 controls to pass in one pass (phased).
- test-kitchen / EC2 / IronBank machinery (kept out, same as `quality-foundation`).
- Changing control logic.

## Decisions

- **Provision states with docker-compose, not test-kitchen.** Reuse and extend the existing `docker-compose.yml`; a hardened state is a second compose service/profile that mounts a hardened `postgresql.conf`/`pg_hba.conf` and runs seed SQL via `docker-entrypoint-initdb.d`. *Alternative rejected:* test-kitchen + kitchen-dokken — heavy, and overkill for a single DB container.
- **Fix the connection wiring first.** Ensure the test role/database and the example input file line up so queries connect (create the expected role/db, or align `pg_dba`/`pg_db`). Without this, thresholds would encode connection noise instead of config findings.
- **Assert with `saf validate threshold`.** Commit one `*.threshold.yml` per state. *Alternative rejected:* hand-parsing JSON in bash — reinvents what SAF already standardizes and is what auditors recognize.
- **Seed thresholds from a captured baseline, then tighten.** Generate the initial vanilla threshold from a real run (pure regression guard), then add hardened-state thresholds asserting specific controls pass as hardening fixtures are written.
- **Phase by control type.** Start with DB-query/config-driven controls (the ones a container can actually harden). OS-file/permission controls (paths, ownership, FIPS) are harder to harden in a stock image — leave them out of the hardened target set initially and document why.
- **SAF CLI dependency.** Use the `mitre/saf_action` GitHub Action (or `npm i -g @mitre/saf`) for threshold validation; no change to the Ruby bundle.

## Risks / Trade-offs

- **OS-level controls don't map cleanly to a container** (the Debian `postgres` image layout differs from the RPM paths the STIG assumes) → scope the hardened set to config/SQL controls first; treat OS-file controls as out-of-target, not failures, via the threshold.
- **Threshold churn**: legitimate control changes require threshold updates → document the regenerate step; keep thresholds readable and per-state.
- **Hardening fixtures can drift from the STIG fix text** → derive each fixture from the control's `desc 'fix'` so the hardened state mirrors the documented remediation.

## Open Questions

- Which controls form the initial hardened target set? (Proposal: the audit/logging and connection/auth settings driven by `postgresql.conf`/`pg_hba.conf`, since those are container-hardenable.)
- Extend the existing `validate.yml` with a state matrix, or add a separate `integration.yml`? (Leaning: separate workflow, since validate is a fast smoke test and integration is slower.)
- `inspec` vs `cinc-auditor` for the runs (inherited from `quality-foundation`).
