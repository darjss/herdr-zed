# herdr-zed

Open the folder you're in, in Zed. On remote machines the folder opens over SSH as a Zed remote project, so the language servers, search, and terminal run on the box instead of your laptop.

Three triggers:

- `zd`, a shell function on the remote box. Sends the path back through the SSH connection and opens it in local Zed. No click needed.
- `prefix+z`, a keybinding that opens the focused pane's cwd. When a remote machine is selected in the herdr sidebar, it reads the remote pane's cwd through `herdr --machine` and opens it via `ssh://`.
- link click. If the forward channel isn't up, `zd` falls back to printing a `zed-remote://` link you ctrl+click.

## Install

```sh
herdr plugin install darjss/herdr-zed
```

Or link a local checkout:

```sh
herdr plugin link /path/to/herdr-zed
```

## Setup

`zd` needs a reverse channel from the remote box to your laptop. Add a `RemoteForward` to the host in `~/.ssh/config` on the client:

```
Host orc
    HostName ...
    RemoteForward 127.0.0.1:9877 127.0.0.1:9877
```

Any ssh connection that reads that config carries the forward, including herdr's machine bridge and a plain `ssh orc`. Only the first connection binds it; later ones print a warning and still work.

A `startup` hook in the plugin spawns `zd-listen.sh`, a small `nc` loop on 127.0.0.1:9877 that runs `zeditor ssh://<host><path>` for each line it receives. No systemd unit, no daemon to manage.

Keybinding in `~/.config/herdr/config.toml`:

```toml
[[keys.command]]
key = "prefix+z"
type = "plugin_action"
command = "darjs.zed-open.open"
description = "Open focused folder in Zed"
```

For `zd`, add a function to your shell on each remote box. The host sent must be the SSH alias from the client's `~/.ssh/config`.

fish (`~/.config/fish/functions/zd.fish`):

```fish
function zd
    if echo "<ssh-alias> $PWD" | nc -w1 localhost 9877 2>/dev/null
        echo "opening in zed"
    else
        set -l url "zed-remote://<ssh-alias>$PWD"
        printf "\e]8;;%s\a%s\e]8;;\a\n" "$url" "$url"
    end
end
```

bash or zsh:

```sh
zd() {
  if ! echo "<ssh-alias> $PWD" | nc -w1 localhost 9877 2>/dev/null; then
    printf '\e]8;;zed-remote://<ssh-alias>%s\a%s\e]8;;\a\n' "$PWD" "zed-remote://<ssh-alias>$PWD"
  fi
}
```

## Requirements

- `zeditor` (or `zed`) on PATH locally. On Arch the binary is `zeditor` since `zed` is the ZFS daemon.
- `nc` on both ends.
- For `prefix+z` on remote panes, the remote herdr needs machine API forwarding. Update the box if `herdr --machine <alias> api snapshot` errors.
- The `zd` link fallback needs nothing beyond the plugin.
