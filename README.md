# bootfiles dotstrap

Dotfiles files and setup manager build thanks to the Internet.

## Usage

	git clone git@github.com:LEI/dotfiles.git ~/.dotfiles
	~/.dotfiles/bootstrap install

	dot --help

### Installer

- Prompt for git credentials
- Link repository dotfiles, .vim & bin folders to home.
- Apply Terminal window settings
- Set defaults (only OS X: init/.osx)
- Install dependencies via Homebrew
- Download application via Caskroom
- Link Preferences.sublime-settings

### Add a dotfile to your home

Just move the dot at the end of the name and place it in a directory before bootstraping

## Inspiration

- Mathias Bynens [@mathiasbynens](//github.com/mathiasbynens) [dotfiles](//github.com/mathiasbynens/dotfiles)
- Zach Holman [@holman](//github.com/holman) [dotfiles](//github.com/mathiasbynens/dotfiles)
- Nicolas Gallagher [@necolas](//github.com/necolas/dotfiles) [dotfiles](//github.com/mathiasbynens/dotfiles)
- Ben Alman [@cowboy](//github.com/cowboy/dotfiles) [OS X / Ubuntu dotfiles](//github.com/cowboy/dotfiles)
- [+](//github.com/ryanb/dotfiles)
- [+](//github.com/tejr/dotfiles)
- [+](//github.com/gf3/dotfiles)
- [+](//github.com/rtomayko/dotfiles)
- [+](//github.com/mikemcquaid/dotfiles)
- [+](//github.com/nicck/dotfiles)
- [+](//github.com/paulirish/dotfiles)
- [+](//github.com/travi/dotfiles)
- [+](//github.com/sitaktif/dotfiles)
- [+](//github.com/zenorocha/dotfiles)
- [+](//gist.github.com/zenorocha/7159780)
- https://github.com/thoughtbot/rcm
- http://dev.svetlyak.ru/dotfiler-en/
- [HomeSick](http://technicalpickles.com/posts/never-leave-your-dotfiles-behind-again-with-homesick/)

## TODO

- Ruby, compass.. http://www.npmjs.org/package/dotfiles
- Sync-home (licences, ssh_config...) CLI [Dropbox](http://www.dropboxwiki.com/tips-and-tricks/using-the-official-dropbox-command-line-interface-cli)
- Opts.. -m, undot
