# dotfiles

[![ci](https://github.com/LEI/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/LEI/dotfiles/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/LEI/dotfiles/branch/main/graph/badge.svg?token=ORK8QFQ9BN)](https://codecov.io/gh/LEI/dotfiles)

Cross-platform dotfiles managed with [chezmoi](https://chezmoi.io).

- [Bash benchmark](https://lei.github.io/dotfiles/dev/bench/)
- [Bash benchmark (macos)](https://lei.github.io/dotfiles/benchmark-macos-latest/)
- [Bash benchmark (ubuntu)](https://lei.github.io/dotfiles/benchmark-ubuntu-latest/)
- [Test coverage](https://lei.github.io/dotfiles/coverage/kcov-merged/)
- [Test coverage (macos)](https://lei.github.io/dotfiles/coverage-macos-latest/test/)
- [Test coverage (ubuntu)](https://lei.github.io/dotfiles/coverage-ubuntu-latest/test/)

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

- [Test documentation](./test)

## Ideas

- [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles): `macos` defaults
- [Paul's dotfiles](https://github.com/paulirish/dotfiles): `macos`, `yay`
- [Tom's dotfiles](https://github.com/twpayne/dotfiles): `chezmoi` [template](https://github.com/chezmoi/dotfiles)
- [shunk031's dotfiles](https://github.com/shunk031/dotfiles): `bats`, `zsh`
