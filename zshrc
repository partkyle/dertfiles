source ~/.zsh/config.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/keybindings.zsh
source ~/.zsh/title.zsh
source ~/.zsh/prompt.zsh

for file in ~/.localrc.d/*; do
  source $file
done

for file in ~/.localrc.zsh.d/*; do
  source $file
done

# aliases
for file in ~/.zsh/aliases/*.zsh; do
  source $file
done

# zsh-syntax-highlighting
if [[ -d ~/.zsh/vendor/zsh-syntax-highlighting ]]; then
  source ~/.zsh/vendor/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

export PATH=~/.dotfiles/bin:$PATH
