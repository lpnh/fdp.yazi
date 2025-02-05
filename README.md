# fdp.yazi

> [!NOTE]
> this plugin is only guaranteed to be compatible with Yazi nightly

a Yazi plugin that adds the `fzf` interface to `fd` with `eza` preview for
directories and `bat` preview for files

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

there are four different arguments available for this plugin

- `cwd`: limits the search to the current directory
- `all`: searches for both files and directories, adding `..` and `.` to the selection
- `dir`: searches for directories only
- `file`: searches for files only

here's an example of how to set them in the `~/.config/yazi/keymap.toml` file:

```toml
[[manager.prepend_keymap]]
on = ["f", "a"]
run = "plugin fdp --args='all'"
desc = "fd with preview (all)"

[[manager.prepend_keymap]]
on = ["f", "c"]
run = "plugin fdp --args='cwd'"
desc = "fd with preview (CWD only)"

[[manager.prepend_keymap]]
on = ["f", "d"]
run = "plugin fdp --args='dir'"
desc = "fd with preview (dirs only)"

[[manager.prepend_keymap]]
on = ["f", "f"]
run = "plugin fdp --args='file'"
desc = "fd with preview (files only)"
```

**bonus:** `<ctrl-space>` switches the preview to display metadata from `eza`
for the selected entry

## acknowledgments

@prosoitos for the [inspiration](https://github.com/sxyazi/yazi/discussions/2273)
