# .dotfiles

Miscellaneous tools and configs tailored for macOS machines.

## Usage

```
$ git clone https://gitlab.com/obxhdx/dotfiles.git ~/.dotfiles
$ ~/.dotfiles/bootstrap.sh
```

The above commands will:

- Install [Homebrew](https://brew.sh) and all dependencies listed on `Brewfile`.
- Install Tmux plugins (listed on `config/tmux.conf`).
- Install Neovim plugins (listed on `config/config/nvim/lua/plugins.lua`).
- Symlink everything from the `config` directory into your `$HOME`.

## Contents

- [Alacritty](https://github.com/alacritty/alacritty), a terminal emulator.
- [Alfred](https://www.alfredapp.com), an alternative to Spotlight.
- [Docker](https://www.docker.com).
- [Doom Emacs](https://github.com/hlissner/doom-emacs) customizations (Doom Emacs needs to be installed separately).
- [FZF](https://github.com/junegunn/fzf), a command-line fuzzy finder.
- [GNU Emacs](https://www.gnu.org/software/emacs), Yamamoto Mitsuharu's Mac port.
- [Gimp](https://www.gimp.org) for image manipulation.
- [LS_COLORS](https://github.com/trapd00r/LS_COLORS) for enhanced `ls` color output.
- [Neovim](https://neovim.io), the Vim-based text editor.
- [Rectangle](https://rectangleapp.com) for moving and resizing windows.
- [Starship](https://starship.rs) for fancy terminal prompts.
- [Tmux](https://github.com/tmux/tmux), a terminal multiplexer, and [tpm](https://github.com/tmux-plugins/tpm) for plugin management.
- [Zsh](https://www.zsh.org), a `bash` alternative, and [zplug](https://github.com/zplug/zplug) for plugin management.
- [base16-shell](https://github.com/chriskempson/base16-shell) for terminal color themes.
- [bat](https://github.com/sharkdp/bat), `cat` on steroids.
- [fasd](https://github.com/clvv/fasd) for quick access to files and directories.
- [fd](https://github.com/sharkdp/fd), `find` on steroids.
- [fnm](https://github.com/Schniz/fnm), blazing fast Node.js version manager.
- [git-delta](https://lib.rs/crates/git-delta), a fancy Git pager.
- [lsd](https://github.com/Peltoche/lsd), `ls` on steroids.
- [ripgrep](https://github.com/BurntSushi/ripgrep), `grep` on steroids.

## Handling sensitive or temporary configs

The following files will be sourced automatically if they exist:

- `~/.emacs.local.el`
- `~/.vimrc.local.vim`

## Additional manual steps

This brings [CoC](https://github.com/neoclide/coc.nvim) as a [LSP client](https://langserver.org) for Neovim. However, no LSP servers are installed by default.

A comprehensive list of available LSP servers and CoC extensions can be found [here](https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions).
