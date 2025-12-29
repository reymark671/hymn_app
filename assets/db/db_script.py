import sqlite3
import re

DB_PATH = "hymns.db"  # 🔧 change if needed

PRIORITY_PREFIXES = ["E", "BF", "NS"]


def hymn_sort_key(hymn_id):
    """
    Sort by numeric part of hymn ID.
    E1 < E2 < E10
    """
    match = re.match(r"([A-Z]+)(\d+)", hymn_id)
    if match:
        return int(match.group(2))
    return float("inf")


conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# 1️⃣ Select hymns without tune
cursor.execute("""
    SELECT _id, related
    FROM hymns
    WHERE tune IS NULL OR tune = ''
""")

hymns_without_tune = cursor.fetchall()
print(f"Found {len(hymns_without_tune)} hymns without tune")

updated_count = 0

for hymn_id, related in hymns_without_tune:
    if not related:
        continue

    related_ids = [r.strip() for r in related.split(",") if r.strip()]

    # 2️⃣ Process by prefix priority
    for prefix in PRIORITY_PREFIXES:
        # Get related hymns with this prefix
        same_prefix = [r for r in related_ids if r.startswith(prefix)]

        # Sort by numeric order (E1 before E2)
        same_prefix.sort(key=hymn_sort_key)

        # 3️⃣ Find first with a tune
        for related_id in same_prefix:
            cursor.execute("""
                SELECT tune
                FROM hymns
                WHERE _id = ?
                  AND tune IS NOT NULL
                  AND tune <> ''
                LIMIT 1
            """, (related_id,))

            row = cursor.fetchone()

            if row:
                tune = row[0]

                cursor.execute("""
                    UPDATE hymns
                    SET tune = ?
                    WHERE _id = ?
                """, (tune, hymn_id))

                updated_count += 1
                print(f"Updated {hymn_id} <- tune from {related_id}")
                break

        # Stop checking lower-priority prefixes if updated
        if cursor.rowcount > 0:
            break

conn.commit()
conn.close()

print(f"Done. Updated {updated_count} hymns.")
