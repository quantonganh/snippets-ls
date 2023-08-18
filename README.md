# snippets-ls
A simple language server to just insert snippets into Helix (and other text editor, IDE)

https://quantonganh.com/2023/07/31/create-snippets-in-helix

## Installation

You can download the latest binary from the [release page](https://github.com/quantonganh/snippets-ls/releases).

### Install via homebrew

```
brew install quantonganh/tap/snippets-ls
```

### Install via go

Due to the presence of a `replace` directive in the [go.mod](https://github.com/quantonganh/snippets-ls/blob/main/go.mod#L13) file, [`go install` cannot be used](https://github.com/golang/go/issues/44840). You have to clone and build the package manually:

```sh
$ git clone git@github.com:quantonganh/snippets-ls.git
$ cd snippets-ls
$ go build -o ~/go/bin/snippets-ls main.go
```

Don't forget to append `~/go/bin` to your `$PATH`.

## Usage

Create your own snippets follow [VSCode syntax](https://code.visualstudio.com/docs/editor/userdefinedsnippets#_create-your-own-snippets). Alternatively, you can make use of [pre-existing](https://github.com/microsoft/vscode-go/blob/master/snippets/go.json) [sample](https://github.com/rust-lang/vscode-rust/blob/master/snippets/rust.json) for various programming languages.

Update your configuration file located at `~/.config/helix/languages.toml`:

```toml
[[language]]
name = "go"
formatter = { command = "goimports"}
language-servers = ["gopls", "snippets-ls"]

[language-server.snippets-ls]
command = "snippets-ls"
args = ["-config", "/Users/quantong/.config/helix/go-snippets.json"]
```

Subsequently, as you start working on your file, input a snippet prefix to observe the suggestion.
If it does not work, take a look at `~/.cache/helix/helix.log` for additional insights.