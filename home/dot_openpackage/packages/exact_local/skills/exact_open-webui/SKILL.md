---
name: open-webui
description: >
  Interact with open-webui REST API: knowledge bases, files, collections.
  Use when the user asks to upload files, sync knowledge, list collections,
  or any open-webui API operation.
---

# open-webui API

## Connection

- Base URL: `$OPEN_WEBUI_URL` (default `https://open-webui.test`)
- Auth: bearer token from signin, captured into `$OAGE_WEBUI_TOKEN`

```sh
OAGE_WEBUI_TOKEN=$(curl -s "$OPEN_WEBUI_URL/api/v1/auths/signin" \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@localhost","password":"admin"}' \
  | jq -r '.token')
```

All subsequent requests use `-H "Authorization: Bearer $OAGE_WEBUI_TOKEN"`.

## Endpoints

### Knowledge collections

- `POST /api/v1/knowledge/create` `{name, description, data:{}}`: create collection
- `GET /api/v1/knowledge/`: list collections (paginated, `.items[]`)
- `GET /api/v1/knowledge/$ID`: get collection
- `POST /api/v1/knowledge/$ID/file/add` `{file_id}`: attach processed file

### Files

- `POST /api/v1/files/` `-F file=@path`: upload file (async, poll before using)
- `GET /api/v1/files/$ID`: check status (`.data.status`: `pending` or `completed`)
- `GET /api/v1/files/`: list all files
- `DELETE /api/v1/files/$ID`: delete file

## Rules

- Never hardcode tokens; capture from signin into `$OAGE_WEBUI_TOKEN`
- Use `jq` for JSON; never python
- Use `$OPEN_WEBUI_URL`; never hardcode the URL
- File upload is async; poll `.data.status` until `completed` before adding to a collection
- Check for duplicates by filename before uploading
- One curl per operation; report errors immediately
