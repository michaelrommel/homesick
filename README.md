## bootstrapping homesick

You can download my homesick bootstrapping file [here](./homesick.sh).
You can bootstrap a new system by using this command:

```
curl -sL https://michaelrommel.github.io/homesick/homesick.sh | /bin/bash -s -e
```

or if a minimalistic install with only homesick and mise is wished for:

```
curl -sL https://michaelrommel.github.io/homesick/homesick.sh | /bin/bash -s -e -- -q
```

It will offer several castles for installation:

- castle-core: will install basic additional apt packages, I typically need on most systems. It will also install `zsh` with `oh-my-zsh` and `powerlevel10k` prompt customization. On WSL2 systems it will compile npiperelay to offer ssh agent integraton with Windows' standard authentication agent. Several terminfo database entries for tmux, kitty and mintty are installed, as well as an up-to-date git command.
- castle-tmux: installs and configures the terminal multiplexer.
- castle-coding: installs several languages, gems, python3, universal-ctags, ripgrep, fzf, fd, bat and bat-extras, shellcheck, fast node manager and node, rust, asciidoctor.
- castle-neovim: compiles neovim and treesitter-cli, installs a sane default configuration.
