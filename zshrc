source ~/.zsh/config.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/keybindings.zsh
source ~/.zsh/title.zsh
source ~/.zsh/prompt.zsh

for file in ~/.localrc.d/*(N); do
  source $file
done

for file in ~/.localrc.zsh.d/*(N); do
  source $file
done

# aliases
for file in ~/.zsh/aliases/*.zsh(N); do
  source $file
done

# zsh-syntax-highlighting
if [[ -d ~/.zsh/vendor/zsh-syntax-highlighting ]]; then
  source ~/.zsh/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# zsh-syntax-highlighting
if [[ -d ~/.zsh/vendor/zsh-history-substring-search ]]; then
  source ~/.zsh/vendor/zsh-history-substring-search/zsh-history-substring-search.zsh

  # bind UP and DOWN arrow keys
  zmodload zsh/terminfo
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down

  # bind P and N for EMACS mode
  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  # bind k and j for VI mode
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down

fi

export PATH=~/.dotfiles/bin:$PATH
