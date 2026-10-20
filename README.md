# Nvim config

## Install via SSH

```sh
git clone git@github.com:imbolc/nvim.git ~/proj/nvim-config
ln -s ~/proj/nvim-config ~/.config/nvim
```

## Update plugins

```vim
:lua vim.pack.update()
:write
```

## Delete plugins that isn't in the config

```sh
  vim --appimage-extract-and-run --headless \
      -c 'lua vim.pack.del(vim.iter(vim.pack.get()):filter(function(p) return not p.active end):map(function(p) return p.spec.name end):totable())' \
      -c 'qa'
```
