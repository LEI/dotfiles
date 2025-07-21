HELIX_DIR ?= ~/src/github.com/helix-editor/helix

.PHONY: helix
helix: ~/.local/bin/hx

# https://docs.helix-editor.com/building-from-source.html
~/.local/bin/hx:
	set -x; \
		test -d $(HELIX_DIR) || \
		git clone --single-branch https://github.com/helix-editor/helix $(HELIX_DIR)
	set -x; \
		cd $(HELIX_DIR) && \
		git status && \
		git checkout master && \
		git pull origin master && \
		(test -f ./target/release/hx || cargo install --path helix-term --locked)
	# git branch -D steel && \
	# git fetch origin pull/8675/head:steel && \
	# git switch steel && \
	# git rebase master && \
	ln -Tsf $(HELIX_DIR)/runtime ~/.config/helix/runtime
	mv $(HELIX_DIR)/target/release/hx ~/.local/bin/hx

.PHONY: clean
clean:
	rm -fr $(HELIX_DIR)/target

.PHONY: uninstall
uninstall:
	rm -f ~/.config/helix/runtime ~/.local/bin/hx
