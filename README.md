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

add this to your `~/.config/yazi/keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = ["f", "d"]
run = "plugin fdp"
desc = "fd with preview"
```

## acknowledgments

@prosoitos for the [inspiration](https://github.com/sxyazi/yazi/discussions/2273)
