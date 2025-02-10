# fdp.yazi

> [!NOTE]
> this plugin is only guaranteed to be compatible with Yazi nightly

a Yazi plugin that integrates `fzf` and `fd`, with `eza` and `bat` previews

**supports**: `bash`, `fish`, and `zsh`

## dependencies

- [bat](https://github.com/sharkdp/bat)
- [fd](https://github.com/sharkdp/fd)
- [fzf](https://junegunn.github.io/fzf/)
- [eza](https://eza.rocks/)

## installation

```sh
ya pack -a lpnh/fdp
```

## usage

### plugin args

this plugin supports four arguments:

- `cwd`: limits the search to the current directory
- `all`: searches for both files and directories
- `dir`: searches for directories only
- `file`: searches for files only

below is an example of how to configure them in the
`~/.config/yazi/keymap.toml` file:

```toml
[[manager.prepend_keymap]]
on = ["f", "a"]
run = "plugin fdp all"
desc = "fd search (all)"

[[manager.prepend_keymap]]
on = ["f", "c"]
run = "plugin fdp cwd"
desc = "fd search (CWD)"

[[manager.prepend_keymap]]
on = ["f", "d"]
run = "plugin fdp dir"
desc = "fd search (dirs)"

[[manager.prepend_keymap]]
on = ["f", "f"]
run = "plugin fdp file"
desc = "fd search (files)"
```

### fzf binds

this plugin provides four custom `fzf` keybindings:

- `<ctrl-f>`: toggle `fzf` match search for the current query results
- `<ctrl-w>`: toggle the preview window size (66%, 80%)
- `<ctrl-\>`: toggle the preview window position (top, right)
- `<ctrl-space>`: display metadata from `eza` for the selected entry

## customization

### color themes

you can customize the default `fzf` colors using the `FZF_DEFAULT_OPTS`
environment variable. for an example, check out [Catppuccin's fzf
repo](https://github.com/catppuccin/fzf?tab=readme-ov-file#usage)

more examples of color themes can be found in the [fzf
documentation](https://github.com/junegunn/fzf/blob/master/ADVANCED.md#color-themes)

## acknowledgments

thanks @prosoitos for the
[inspiration](https://github.com/sxyazi/yazi/discussions/2273)
