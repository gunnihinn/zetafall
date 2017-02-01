# SQL

Move database from file system to SQLite.

# Post tool

Detect whether we're editing a JSON post or creating a new one. Act accordingly.

Use a JSON parser to handle JSON. Doing it by hand will fail the first time you
have to escape anything.

When editing posts, write to temp file, edit file in $EDITOR, then parse to JSON
and write that.

# Templates

Move index.html to its own templates directory. Copy that to server.
