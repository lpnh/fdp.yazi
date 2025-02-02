# fdp.yazi

> [!NOTE]
> this plugin is only guaranteed to be compatible with Yazi nightly

a Yazi plugin that integrates `fzf` to enhance `fd` with an `eza` preview for directories and a `bat` preview for files. essentially, `fd` with preview

**supports**: `bash`, `fish`, and `zsh`

## dependencies

- `bat`
- `fd`
- `fzf`
- `eza`

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
