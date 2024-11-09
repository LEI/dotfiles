# dotfiles

## Install

<!-- https://www.chezmoi.io/user-guide/daily-operations/#install-chezmoi-and-your-dotfiles-on-a-new-machine-with-a-single-command -->
<!-- sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME -->

Manually install [`chezmoi`](https://www.chezmoi.io/install/) and run this command
to clone using SSH:

```bash
GITHUB_USERNAME=LEI
chezmoi init --apply --interactive git@github.com:$GITHUB_USERNAME/dotfiles.git
```

Or automatically install `chezmoi` and clone using HTTPS:

```bash
GITHUB_USERNAME=LEI
URL="https://raw.githubusercontent.com/$GITHUB_USERNAME/dotfiles/refs/heads/main/script/bootstrap"
curl -LSfs "$URL" | sh -s -- --interactive "$GITHUB_USERNAME"
# or
wget -qO- "$URL" | sh -s -- --interactive "$GITHUB_USERNAME"
```

## Usage

Clone repo:

```bash
chezmoi init "$GITHUB_USERNAME"
```

Show diff:

```bash
chezmoi diff --exclude=scripts
```

Update and apply:

```bash
chezmoi update --apply --init --interactive
```
