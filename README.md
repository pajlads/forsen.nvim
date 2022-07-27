# Forsen.nvim

This plugin allow you to write [ForsenCode](GaZaTu/ca2e6e1c9abd8b2da35b9b2d73919ac8/raw/cfbef5546a6da64d90c9e90d13d2c385b416fc31/forsencode-rfc.txt) inside your neovim

## Show case
[![asciicast](https://asciinema.org/a/511175.png)](https://asciinema.org/a/511175)

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
- Decode lines of text using `ForsDecode` command

## Example usages:
- `nvim foo.forsen` to edit a `forsen` file, encoding will be automatically enabled
- `ForsEnable` when you type text in string literal to obfuscate them
- highlight lines and use `ForsEncode` to obfuscate them

## Notes:
- only characters in ASCII range 32-126 and <Tab> are encoded. Notably, `<Space>`, `<CR>` aren't encoded. This is to allow you to nicely format your ForsenCode by adding space between codeword or splitting into lines

## Limitation
- in insert mode `<space>` is always encoded even it is immediately follows non-ascii character. This might not be 100% compliant with the ForsenCode RFC
- due to how keymap are set (overwrite)/unset, it might break compatibility with plugins that sets keymap in insert mode


## TODO
- operators to use with text object / motion


## LICENSE
The MIT License (MIT)

Copyright (c) 2022 rod41732

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
