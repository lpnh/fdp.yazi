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

this plugin provides the following custom `fzf` keybindings:

- `ctrl-s`: toggle `fzf` match search for the current query results
- `ctrl-]`: toggle the preview window size (66%, 80%)
- `ctrl-\`: toggle the preview window position (top, right)
- `alt-m`: switch the preview to "metadata" with `eza -l`
- `alt-c`: switch the preview to "content" with `eza` or `bat` (default)

## customization

### color themes

#### fzf

you can customize the default `fzf` colors using the `FZF_DEFAULT_OPTS`
environment variable. for an example, check out [Catppuccin's fzf
repo](https://github.com/catppuccin/fzf?tab=readme-ov-file#usage)

more examples of color themes can be found in the [fzf
documentation](https://github.com/junegunn/fzf/blob/master/ADVANCED.md#color-themes)

#### eza

you can customize the colors of `eza` previews using its
`~/.config/eza/theme.yml` configuration file. check the
[eza-theme](https://github.com/eza-community/eza-themes) repository for some
existing themes

for more details, see
[eza_colors-explanation](https://github.com/eza-community/eza/blob/main/man/eza_colors-explanation.5.md)

## acknowledgments

thanks @prosoitos for the
[inspiration](https://github.com/sxyazi/yazi/discussions/2273)
