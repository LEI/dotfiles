---
name: sq
description: >
  This skill should be used when the user asks to "query a database", "query a CSV", "query Excel",
  "use sq", "inspect a data source", "join two data sources", "export query results", "run SQL against
  a file", "copy data between sources", or mentions sq CLI for MySQL, PostgreSQL, SQLite, CSV, or
  Excel data queries. Also use when the user wants to explore an unknown schema or compare data across
  files.
version: 0.1.0
allowed-tools: "Bash(sq *)"
---

# sq data query CLI

`sq` queries databases and files (MySQL, PostgreSQL, SQLite, CSV, Excel) with a jq-like syntax.
Use it to inspect schemas, run queries, join across sources, and export results without writing
throwaway scripts.

## Source management

List and inspect configured sources before querying:

```bash
sq ls                        # list all configured sources
sq inspect @src              # schema overview: tables and row counts
sq inspect @src.table        # column details: names, types, nullability
```

Add a source for the session or permanently:

```bash
sq add ./data.csv            # auto-detected as CSV, assigned handle @data
sq add ./report.xlsx         # Excel
sq add sqlite:///path/to.db  # SQLite
sq add 'postgres://user:pass@host/db'  # PostgreSQL (prompt for password if omitted)
sq add --handle @mydb sqlite:///path/to.db  # explicit handle
```

Always run `sq inspect` on an unknown source before querying to understand the schema.

## Query syntax

Use the jq-like pipe syntax for column selection and filtering:

```bash
sq '@src.table | .col1, .col2'              # select columns
sq '@src.table | where(.col == "val")'      # filter rows
sq '@src.table | where(.col == "val") | .col1, .col2'  # filter then select
sq '@src.table | .[0:10]'                   # first 10 rows (slice)
sq '@src.table | order_by(.col)'            # sort ascending
sq '@src.table | order_by(.col | desc)'     # sort descending
```

## Native SQL

Use SQL when the pipe syntax is insufficient or when porting existing queries:

```bash
sq sql --src=@src "SELECT col1, COUNT(*) FROM table GROUP BY col1"
sq sql --src=@src "SELECT * FROM t WHERE col LIKE '%pattern%'"
```

## Cross-source join

Join tables from different sources in a single query:

```bash
sq '@s1.t1, @s2.t2 | join(.key) | .col1, .col2'
sq '@csv.sheet1, @db.users | join(.email) | .name, .status'
```

This is sq's primary advantage: no ETL needed to correlate data across file types or databases.

## Output formats

| Flag | Format |
|------|--------|
| (none) | table, printed to stdout |
| `-j` | JSON array |
| `--csv` | CSV |
| `--xlsx` | Excel |
| `-o file.ext` | write to file (format inferred from extension) |

```bash
sq '@src.table | .col1' --csv -o results.csv
sq '@src.table | .col1' -j | jq '.[] | .col1'   # pipe JSON to jq
```

## Insert / copy data

Copy rows between sources without intermediate files:

```bash
sq --insert=@dest.table '@src.table | .col1, .col2'
sq --insert=@db.users '@csv.users | .name, .email'   # CSV → database
```

## Typical workflow

When asked to query or explore a data source:

- Add the source if not already listed in `sq ls`
- Run `sq inspect @src` to understand the schema
- Start with a limited query (`.[0:5]`) to verify the shape of data
- Refine the query based on what you find
- Export to the format the user needs (`-o file.ext`)

For cross-source joins, inspect both sources first to confirm the join key names match.
