source $HOME/.zsh/config.zsh
source $HOME/.zsh/completion.zsh
source $HOME/.zsh/keybindings.zsh
source $HOME/.zsh/title.zsh
source $HOME/.zsh/prompt.zsh

for file in $HOME/.localrc.d/*(N); do
  source $file
done

for file in $HOME/.localrc.zsh.d/*(N); do
  source $file
done

# aliases
for file in $HOME/.zsh/aliases/*.zsh(N); do
  source $file
done

source $HOME/.zsh/antigen.zsh

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-history-substring-search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# setup bin files
export PATH=~/.dotfiles/bin:$PATH
