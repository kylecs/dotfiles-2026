# nvim

A small hand-rolled config for Neovim 0.12+, modelled on my Emacs setup
(`kylecs/.emacs.d`). Kitty is just the window. Neovim does the splits, tabs
and terminals, so there's no tmux and no key-routing plugins.

```
init.lua
lua/config/   options, keymaps (the SPC leader tree), autocmds, lazy bootstrap
lua/kyle/     my own modules: term, project, theme, tabline, util
lua/plugins/  one file per plugin
colors/       acario-light, ported from doom-themes
```

## Terminals (`SPC t`)

Key routing matches evil-ghostel:

| where         | key                    | does                                              |
|---------------|------------------------|---------------------------------------------------|
| terminal mode | anything               | goes to the program (`C-c`, `C-d`, `C-r`, ...)    |
| terminal mode | `Esc`                  | normal mode: motions, yank, `/` over scrollback   |
| terminal mode | `C-Esc`                | sends a literal Esc (vim, fzf, claude inside)     |
| terminal mode | `C-Space`              | leader menu                                       |
| everywhere    | `C-h/j/k/l`            | move between windows                              |
| normal mode   | `Esc` `C-c` `Up` `Down`| forwarded to the program                          |
| normal mode   | `i` / `a`              | back to terminal mode                             |

Each terminal remembers the mode you left it in. A shell that exits cleanly
closes its window, tmux-style. lazygit (`SPC p v`) gets Esc passed straight
through.

`SPC t t` open or reuse · `t n` new here · `t p` new at the project root ·
`t b`/`t B` pick (all / project) · `t ]`/`t [` cycle · `t c`/`t C` clear ·
`t r` rename

## Everything else

The leader tree follows the Emacs one: `f` files, `b` buffers, `p` projects,
`s` search, `w` windows, `a` activities (named sessions), `c` code, `h` help,
`u` ui (`u t` switches gruvbox ⇄ acario-light), `e` tree sidebar, `j` jump,
`,` buffers, `.` find file, `q q` quit. `H`/`L` switch tabs, `-` opens the
parent directory in oil, `C-s` saves.

Language servers come from `$PATH` (no mason). Any that aren't installed are
skipped.
