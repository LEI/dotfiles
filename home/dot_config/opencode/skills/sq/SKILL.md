---
name: sq
description: Query MySQL, PostgreSQL, SQLite, Excel, CSV with sq CLI
---

Sources:

```bash
sq ls                      # list
sq inspect @src            # schema
sq inspect @src.table      # columns
```

Query (jq-like):

```bash
sq '@src.table | .col1, .col2'
sq '@src.table | where(.col == "val") | .col1'
sq '@src.table | .[0:10]'
```

Native SQL:

```bash
sq sql --src=@src "SELECT * FROM t WHERE cond"
```

Cross-source join:

```bash
sq '@s1.t1, @s2.t2 | join(.key) | .col1, .col2'
```

Output: `-t` table, `-j` json, `--csv`, `--xlsx`, `-o file.csv`

Insert:

```bash
sq --insert=@dest.table '@src.table | .col1'
```
