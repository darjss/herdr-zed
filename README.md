# herdr-zed

Open the folder you're in, in Zed. On remote machines the folder opens over SSH as a Zed remote project, so the language servers, search, and terminal run on the box instead of your laptop.

Two triggers:

- `zd` — a shell function that prints a clickable link in the pane. Ctrl+click opens that folder in Zed.
- `prefix+z` — a keybinding that opens the focused pane's cwd. When a remote machine is selected in the herdr sidebar, it reads the remote pane's cwd through `herdr --machine` and opens it via `ssh://`.

## Install

```sh
herdr plugin install darjs/herdr-zed
```

Or link a local checkout:

```sh
herdr plugin link /path/to/herdr-zed
```

## Setup

Keybinding in `~/.config/herdr/config.toml`:

```toml
[[keys.command]]
key = "prefix+z"
type = "plugin_action"
command = "darjs.zed-open.open"
description = "Open focused folder in Zed"
```

For `zd`, add a function to your shell on each remote box. The host in the URL must be the SSH alias from the client's `~/.ssh/config`, not the machine's hostname.

fish (`~/.config/fish/functions/zd.fish`):

```fish
function zd
    set -l url "zed-remote://<ssh-alias>$PWD"
    printf "\e]8;;%s\a%s\e]8;;\a\n" "$url" "$url"
end
```

bash or zsh:

```sh
zd() {
  printf '\e]8;;zed-remote://<ssh-alias>%s\a%s\e]8;;\a\n' "$PWD" "zed-remote://<ssh-alias>$PWD"
}
```

The `zed-remote://` scheme is just a marker. The plugin's link handler catches the click and runs `zeditor ssh://<alias><path>` locally.

## Requirements

- `zeditor` (or `zed`) on PATH locally. On Arch the binary is `zeditor` since `zed` is the ZFS daemon.
- For `prefix+z` on remote panes, the remote herdr needs machine API forwarding. Update the box if `herdr --machine <alias> api snapshot` errors.
- The `zd` link path needs nothing beyond the plugin.
