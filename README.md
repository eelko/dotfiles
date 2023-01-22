# .dotfiles

Miscellaneous tools and configs tailored for MacOS machines.

## Usage

The command below will install all packages and create the appropriate symlinks
under `$HOME`.

```
$ git clone https://gitlab.com/obxhdx/dotfiles.git ~/.dotfiles
$ ~/.dotfiles/bootstrap.sh
```

## Main packages

- [Alfred](https://www.alfredapp.com), an alternative to Spotlight.
- [Doom Emacs](https://github.com/hlissner/doom-emacs) customizations (Doom
  Emacs needs to be installed separately).
- [FZF](https://github.com/junegunn/fzf), a command-line fuzzy finder.
- [Fish](https://fishshell.com) shell.
- [Gimp](https://www.gimp.org) for image manipulation.
- [LS_COLORS](https://github.com/trapd00r/LS_COLORS) for enhanced `ls` color
  output.
- [Neovim](https://neovim.io), the Vim-based text editor.
- [Rectangle](https://rectangleapp.com) for moving and resizing windows.
- [Starship](https://starship.rs) for fancy terminal prompts.
- [WezTerm](https://wezfurlong.org/wezterm/), a GPU-accelerated cross-platform
  terminal emulator and multiplexer.
- [Zsh](https://www.zsh.org), a `bash` alternative, and
- [bat](https://github.com/sharkdp/bat), `cat` on steroids.
- [fd](https://github.com/sharkdp/fd), `find` on steroids.
- [fnm](https://github.com/Schniz/fnm), blazing fast Node version manager.
- [git-delta](https://lib.rs/crates/git-delta), a fancy Git pager.
- [lsd](https://github.com/Peltoche/lsd), `ls` on steroids.
- [ripgrep](https://github.com/BurntSushi/ripgrep), `grep` on steroids.
- [zoxide](https://github.com/ajeetdsouza/zoxide) for quick access to files and
  directories.
- [️Znap](https://github.com/marlonrichert/zsh-snap) for managing Zsh plugins.

## Handling sensitive or temporary configs

The following files will be loaded automatically if they exist:

- `~/.emacs.local.el`
- `~/.config/nvim/lua/config/local.lua`

## Extra manual steps

This brings [CoC](https://github.com/neoclide/coc.nvim) as a
[LSP client](https://langserver.org) for Neovim. However, no LSP servers are
installed by default.

A comprehensive list of available LSP servers and CoC extensions can be found
[here](https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions).

The `extras` folder will contain files that need to be handled manually.
