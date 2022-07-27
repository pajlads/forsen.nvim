# Forsen.nvim

This plugin allow you to write [ForsenCode](GaZaTu/ca2e6e1c9abd8b2da35b9b2d73919ac8/raw/cfbef5546a6da64d90c9e90d13d2c385b416fc31/forsencode-rfc.txt) inside your neovim


## Installation

Install normally using your plugin manager.

- packer.nvim
```
use "rod41732/forsen.nvim"
```

## Features
- Automatically encode text as you type in insert mode
  - use the command `ForsEnable`/`ForsDisable` to enable/disable this feature
  - enabled automatically in `.forsen` files
- Encode lines of text using `ForsEncode` command

## Notes:
- only characters in ASCII range 32-126 and <Tab> are encoded. Notably, `<Space>`, `<CR>` aren't encoded. This is to allow you to nicely format your ForsenCode by adding space between codeword or splitting into lines

## Limitation
- in insert mode `<space>` is always encoded even it is immediately follows non-ascii character. This might not be 100% compliant with the ForsenCode RFC
- due to how keymap are set (overwrite)/unset, it might break compatibility with plugins that sets keymap in insert mode


## TODO
- `ForsDecode` (the counterpart to `ForsEncode` command)
- operators to use with text object / motion
