#!/bin/sh
# Open the focused folder in Zed.
#
# Invocation paths:
#   link click   zed-remote://<ssh-host>/<abs-path>  ->  zeditor ssh://<host><path>
#   keybinding   machine selected in sidebar         ->  remote focused pane cwd
#   keybinding   local workspace selected            ->  local focused pane cwd
set -eu

herdr="${HERDR_BIN_PATH:-herdr}"

if [ -n "${HERDR_PLUGIN_CLICKED_URL:-}" ]; then
  rest=${HERDR_PLUGIN_CLICKED_URL#zed-remote://}
  host=${rest%%/*}
  path="/${rest#*/}"
else
  host=$("$herdr" machine list --json | python3 -c '
import sys, json
print(next((m["target"] for m in json.load(sys.stdin) if m.get("selected") and m.get("enabled")), ""))')
  if [ -n "$host" ]; then
    path=$("$herdr" --machine "$host" api snapshot | python3 -c '
import sys, json
s = json.load(sys.stdin)["result"]["snapshot"]
fp = s.get("focused_pane_id")
panes = s.get("panes", [])
pane = next((p for p in panes if p.get("pane_id") == fp), panes[0] if panes else {})
print(pane.get("foreground_cwd") or pane.get("cwd") or "")')
  else
    path=$(printf %s "${HERDR_PLUGIN_CONTEXT_JSON:-{\}}" | python3 -c '
import sys, json
print(json.load(sys.stdin).get("focused_pane_cwd") or "")')
  fi
fi

[ -n "$path" ] || exit 0

if [ -n "$host" ]; then
  exec zeditor "ssh://$host$path"
fi
exec zeditor "$path"
