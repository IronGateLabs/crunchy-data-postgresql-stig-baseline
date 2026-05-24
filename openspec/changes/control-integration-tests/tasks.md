## 1. Fix connection wiring

- [x] 1.1 Reproduce the `database "testuser" does not exist` failures and confirm the cause: ~21 of 164 `sql.query` calls pass no db, so psql defaults the dbname to the user (`testuser`), which doesn't exist
- [x] 1.2 Create the `testuser` database in `init.sql` so those cluster-level/no-db queries connect (verified via psql)
- [~] 1.3 Re-run the profile against the vanilla DB and confirm results reflect config findings, not connection errors (verifying via validate CI)

## 2. Vanilla state + regression threshold

- [ ] 2.1 Capture a baseline run against the vanilla docker-compose DB to JSON
- [ ] 2.2 Generate `vanilla.threshold.yml` from that baseline (regression guard)
- [ ] 2.3 Add `saf validate threshold` against the vanilla result and confirm it passes

## 3. Hardened state

- [ ] 3.1 Choose the initial hardened target set (config/SQL-driven controls, per design Open Question)
- [ ] 3.2 Add hardened fixtures derived from each target control's `desc 'fix'` (hardened `postgresql.conf`/`pg_hba.conf` + seed SQL) as a second compose service/profile
- [ ] 3.3 Run the profile against the hardened state and confirm the target controls report `passed`
- [ ] 3.4 Generate `hardened.threshold.yml` asserting the target controls pass; document non-target (OS-file) controls as expected-not-passing

## 4. CI integration

- [ ] 4.1 Add an integration workflow (PR + default-branch push) running the state matrix (vanilla, hardened), each: provision → run profile → `saf validate threshold`
- [ ] 4.2 Fail the job on any threshold violation; upload per-state result JSON as artifacts

## 5. Wrap-up

- [ ] 5.1 Document how to regenerate thresholds when controls legitimately change
- [ ] 5.2 Verify the integration workflow runs green on a test PR
