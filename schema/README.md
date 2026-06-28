# Schemas

JSON Schemas for chezmoi-managed data files, kept outside `home/` on purpose.

Chezmoi loads every data-extension file under a `.chezmoidata/` directory, and
treats any `.chezmoidata.<format>` file as a data source. A schema colocated
with the data it validates would therefore be ingested as template data: its
top level (`$schema`, `type`, `required`, `properties`) leaks into the global
namespace, and chezmoi doctor flags it as a suspicious entry.

This tree mirrors the source path of each data file, so a schema stays
discoverable without sitting in chezmoi's `.chezmoidata` namespace:

- `home/.chezmoidata/ai.yaml` is validated by `schema/home/.chezmoidata/ai.schema.json`
- `home/dot_config/mimeapps/.chezmoidata.yaml` is validated by
  `schema/home/dot_config/mimeapps/.chezmoidata.schema.json`

`script/validate-schema` resolves a data file's schema by checking, in order,
an inline `$schema` key, a colocated `<stem>.schema.json` sibling, then the
mirrored path under `schema/`. Files that carry an inline `$schema` or a
colocated sibling are unaffected, only chezmoi data files use this tree.
