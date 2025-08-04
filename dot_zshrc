# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.local/cache/histfile
HISTSIZE=1000
SAVEHIST=100000
setopt notify
unsetopt beep
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

autoload -Uz compinit
compinit
# source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme

# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#eval "$(oh-my-posh init zsh --config ~/.local/share/oh-my-posh-themes/powerlevel10k_rainbow.omp.json)"
#eval "$(oh-my-posh init zsh --config ~/.local/share/oh-my-posh-themes/catppuccin_mocha.omp.json)"
eval "$(starship init zsh)"
autoload -U select-word-style
select-word-style bash
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
bindkey "\C-P" up-line-or-beginning-search # C-p
bindkey "\C-N" down-line-or-beginning-search # C-n

alias ls='ls --color=auto'

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
