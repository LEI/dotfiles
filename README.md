# dotfiles

LEI's dotfiles, managed with [chezmoi](https://chezmoi.io).

## Install

```bash
chezmoi init LEI
```

<!-- https://www.chezmoi.io/user-guide/daily-operations/#install-chezmoi-and-your-dotfiles-on-a-new-machine-with-a-single-command -->
<!-- sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME -->

<!--
Manually install [`chezmoi`](https://www.chezmoi.io/install/) and run this command
to clone using SSH:

```bash
GITHUB_TOKEN=
chezmoi secret keyring set --service=github --user=$GITHUB_USERNAME --value=$GITHUB_TOKEN

GITHUB_USERNAME=LEI
chezmoi init --apply --interactive git@github.com:$GITHUB_USERNAME/dotfiles.git
```

Or automatically install if needed, and clone using HTTPS:

```bash
GITHUB_USERNAME=LEI
URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/dotfiles/refs/heads/main/script/bootstrap"
curl -LSfs "$URL" | sh -s -- --interactive "$GITHUB_USERNAME"
# or
wget -qO- "$URL" | sh -s -- --interactive "$GITHUB_USERNAME"
```
-->

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
chezmoi diff --dry-run --verbose
```

Update, init and apply:

```bash
chezmoi update --apply --init
```

## Development

```bash
prek install
```

## Ideas

- [Mathias’s dotfiles](https://github.com/mathiasbynens/dotfiles)
- [Paul's dotfiles](https://github.com/paulirish/dotfiles)
- [Tom's dotfiles](https://github.com/twpayne/dotfiles)
