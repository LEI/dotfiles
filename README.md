# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).

- [Bash benchmark](https://lei.github.io/dotfiles/dev/bench/)

## Install

<!--
<details>
  <summary>cURL</summary>

```bash
curl -LSfs https://lei.github.io/dotfiles/script/bootstrap | sh -s -- --interactive LEI
```

</details>

<details>
  <summary>Wget</summary>

```bash
wget -qO- https://lei.github.io/dotfiles/script/bootstrap | sh -s -- --interactive LEI
```

</details>

```bash
chezmoi secret keyring set --service=github --user=LEI --value=$GITHUB_TOKEN
chezmoi init LEI --apply --interactive git@github.com:LEI/dotfiles.git
```
-->

```bash
chezmoi init LEI
```

## Usage

> [!TIP]
> Use the `--interactive` flag to prompt for all changes and `--verbose` to show
> more output.

<!--
Clone, init and apply:

```bash
chezmoi init --apply "$GITHUB_USERNAME"
```
-->

Show diff:

```bash
chezmoi diff
```

Update, init and apply:

```bash
chezmoi update --init --apply
```

---

Verify installation:

```bash
mise run check
```

## Development

```bash
prek install
```

- [Test](./test)

## Ideas

- [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles): `macos` defaults
- [Paul's dotfiles](https://github.com/paulirish/dotfiles): `macos`, `yay`
- [Tom's dotfiles](https://github.com/twpayne/dotfiles): `chezmoi` [template](https://github.com/chezmoi/dotfiles)
- [shunk031's dotfiles](https://github.com/shunk031/dotfiles): `bats`, `zsh`
