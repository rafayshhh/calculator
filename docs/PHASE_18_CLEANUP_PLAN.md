# CALCULATOR — PHASE 18 CLEANUP PLAN

## Proposed Deletions & Hygenic Actions

### 1. Test/Local Database Artifacts (Root directory)
* **Target Files**:
  * `test_large_history_box.hive`
  * `test_hive_favorites/`
  * `test_hive_migration/`
* **Purpose/Classification**: Local test runner SQLite/Hive temporary databases produced during local automated test runs.
* **Referenced?**: No.
* **Risk**: Low. Safe to remove.
* **Action**: Delete local test database outputs.

### 2. .gitignore Enhancements
* **Target File**: `.gitignore`
* **Changes**: Ensure `test_hive_*`, `test_*.hive`, `*.hive`, and test database directories are comprehensively ignored so future test executions do not leave uncommitted local SQLite/Hive files in the repository.
* **Risk**: Low.
* **Action**: Update `.gitignore`.
