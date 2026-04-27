# PowerSync Sync Streams Feasibility Assessment

**Date:** 2026-04-26
**Status:** Compatible with project requirements
**Recommendation:** Proceed with PowerSync Sync Streams for offline-first implementation

---

## Executive Summary

PowerSync Sync Streams (beta) is production-ready and fully compatible with the project's offline-first patterns. ULID primary keys, soft-delete via tombstone pattern, and bidirectional sync with conflict resolution are all supported. No blocking limitations identified.

---

## Sync Streams (Beta) Status

**Release State:** Beta (production-ready)
**Recommendation:** Use for all new projects
**Migration Path:** Migration guide available from legacy Sync Rules

**Key Features:**

- SQL-based stream definitions in YAML format
- CTE (Common Table Expression) support
- Auto-subscribe on client connect
- Priority-based sync ordering
- Parameter-based data filtering (auth, subscription, connection)

**Configuration Example:**

```yaml
config:
  edition: 3
  streams:
    todos:
      query: SELECT * FROM todos WHERE owner_id = auth.user_id()

```

---

## ULID Primary Key Compatibility

**Requirement:** PowerSync requires `id` column of type `text`

**Finding:** **COMPATIBLE**

- ULIDs are text-based strings (26 characters)
- Can be used directly as the `id` column
- No transformation required in stream queries
- Client-side generation supported via `uuid()` helper or custom ULID generation

**Implementation:**

```sql
-- Database schema uses ULID
CREATE TABLE todos (
  id TEXT PRIMARY KEY,  -- ULID stored as text
  -- other columns
);

-- Sync Stream query (no aliasing needed)
SELECT * FROM todos WHERE owner_id = auth.user_id()

```

**Note:** If backend uses different column name (e.g., `ulid_id`), alias in stream query:

```sql
SELECT ulid_id as id, * FROM todos WHERE owner_id = auth.user_id()

```

---

## Soft-Delete Compatibility

**Requirement:** Tombstone pattern for soft deletes

**Finding:** **COMPATIBLE**

PowerSync does not have built-in soft-delete but supports the pattern via:

1. **Deleted Flag Approach:**

   - Add `deleted_at` timestamp column
   - Filter out deleted records in stream queries
   - Sync the flag to all clients

2. **Cascading Deletes:**

   - PowerSync respects database cascade deletes
   - When backend performs cascade delete, local records deleted automatically

3. **Delete Wins Policy:**

   - DELETE operations always win over updates
   - If one client deletes a row, future updates to that row are ignored
   - Row can be recreated with same ID

**Implementation:**

```sql
-- Schema with soft-delete
CREATE TABLE todos (
  id TEXT PRIMARY KEY,
  deleted_at TIMESTAMPTZ,
  -- other columns
);

-- Stream query filters deleted records
SELECT * FROM todos 
WHERE owner_id = auth.user_id() 
  AND deleted_at IS NULL

```

**Alternative:** Use separate tombstone table for audit trail (documented in PowerSync conflict resolution patterns).

---

## Bidirectional Sync Limitations

**Finding:** **NO CRITICAL LIMITATIONS**

**Default Behavior:**

- Full bidirectional sync supported
- Last write wins (LWW) at field level
- Per-client incrementing operation ID for deduplication
- Backend can implement idempotent operations

**Known Limitations:**

1. **No Peer-to-Peer Sync:** All sync flows through server (server-client architecture)

2. **Field-Level LWW Default:** May not suit all business logic (customizable)

3. **Delete Wins:** Cannot update a deleted record (by design)

**Mitigation:** All limitations are by design and addressable via custom conflict resolution.

---

## Conflict Resolution Strategies

**Default:** Last write wins per field

**Custom Strategies Available:**

1. **Timestamp-Based Detection:** Compare `updated_at` timestamps

2. **Sequence Number Versioning:** Use incrementing version column

3. **Field-Level LWW:** Merge fields from different clients

4. **Business Rule Validation:** Reject updates based on state (e.g., completed orders)

5. **Server-Side Conflict Recording:** Log conflicts for manual resolution UI

6. **Change-Level Status Tracking:** Track individual change status (pending, processed, conflicted)

7. **Cumulative Operations:** For inventory counters, apply deltas instead of overwriting

**Project Alignment:**

- Outbox pattern: Supported via operation tracking
- Idempotency keys: Supported via per-client operation IDs
- Tombstone pattern: Supported via deleted_at flag or separate table

---

## Compatibility with Project Offline-First Patterns

### CrossCuttingOffline Service Requirements

| Requirement | PowerSync Support | Notes |
|-------------|-------------------|-------|
| Outbox pattern | ✅ Supported | Operation tracking built-in |
| Idempotency keys | ✅ Supported | Per-client operation IDs |
| Conflict resolution | ✅ Supported | 7 strategies available |
| Tombstone pattern | ✅ Supported | Via deleted_at flag or separate table |

### OfflineSyncEngine Requirements

| Requirement | PowerSync Support | Notes |
|-------------|-------------------|-------|
| Tombstone pattern | ✅ Supported | Via deleted_at flag |
| ULID primary keys | ✅ Supported | Text type compatible |
| Conflict resolution | ✅ Supported | Custom strategies available |
| Bidirectional sync | ✅ Supported | Full support |

---

## Recommendations

1. **Proceed with PowerSync Sync Streams** for offline-first implementation
2. **Use ULID as primary key** stored in `id` column (TEXT type)
3. **Implement soft-delete** via `deleted_at` timestamp flag
4. **Filter deleted records** in sync stream queries
5. **Implement custom conflict resolution** for business-critical fields (e.g., task status, project deadlines)
6. **Use timestamp-based conflict detection** as default strategy
7. **Consider server-side conflict recording** for manual resolution UI in Phase 1+

---

## Open Questions

None identified. All project requirements are supported.

---

## References

- [Sync Streams Overview](https://docs.powersync.com/sync/streams/overview)
- [Custom Conflict Resolution](https://docs.powersync.com/handling-writes/custom-conflict-resolution)
- [Handling Update Conflicts](https://docs.powersync.com/usage/lifecycle-maintenance/handling-update-conflicts)
- [Client ID Requirements](https://docs.powersync.com/usage/sync-rules/client-id)
- [Data Queries](https://docs.powersync.com/usage/sync-rules/data-queries)
- Context: Rules BE-08, BE-09; ADR_084; 50-XCT-DATA.md offline section
