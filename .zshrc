[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'


# colorful file listings
if [ -n "${commands[dircolors]}" ]; then
    eval $(dircolors ~/.dir_colors)
fi

export PAGER="less --RAW-CONTROL-CHARS" # less with colors

# colorize manpages (when using less as pager)
export LESS_TERMCAP_mb=$(printf "\33[01;34m")   # begin blinking
export LESS_TERMCAP_md=$(printf "\33[01;34m")   # begin bold
export LESS_TERMCAP_me=$(printf "\33[0m")       # end mode
export LESS_TERMCAP_se=$(printf "\33[0m")       # end standout-mode
export LESS_TERMCAP_so=$(printf "\33[44;1;37m") # begin standout-mode - info box
export LESS_TERMCAP_ue=$(printf "\33[0m")       # end underline
export LESS_TERMCAP_us=$(printf "\33[01;35m")   # begin underline

# fzf fuzzy file finder
# .git is ignored via ~/.agignore
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_DEFAULT_OPTS="-x -m --ansi --exit-0 --select-1" # extended match and multiple selections

export DISABLE_AUTO_UPDATE="true" # disable oh-my-zsh auto-update
export DISABLE_UPDATE_PROMPT="true" # disable oh-my-zsh update prompt
export ZSH_THEME="" # disable oh-my-zsh themes
ZSH_DISABLE_COMPFIX=true

source "${HOME}/.zgen/zgen.zsh"
if ! zgen saved; then
    echo "creating zgen save..."
    zgen oh-my-zsh # oh-my-zsh default settings

    zgen load rupa/z # jump to most used directories
    zgen load dottr/dottr

    zgen load denysdovhan/spaceship-prompt spaceship
    zgen load b4b4r07/zsh-vimode-visual
    zgen load zsh-users/zsh-autosuggestions
    zgen load zsh-users/zsh-syntax-highlighting # must be loaded last (https://github.com/zsh-users/zsh-syntax-highlighting#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file)

    zgen save
fi

SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  # hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  # node          # Node.js section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  # golang        # Go section
  # php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  # docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  ubunix
  nixshell
  # dotnet        # .NET section
  # ember         # Ember.js section
  # terraform     # Terraform workspace section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_GIT_STATUS_STASHED=""

# ubunix spaceship prompt
SPACESHIP_UBUNIX_SHOW="${SPACESHIP_UBUNIX_SHOW=true}"
SPACESHIP_UBUNIX_PREFIX="${SPACESHIP_UBUNIX_PREFIX="in "}"
SPACESHIP_UBUNIX_SUFFIX="${SPACESHIP_UBUNIX_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_UBUNIX_SYMBOL="${SPACESHIP_UBUNIX_SYMBOL="UBUNIX "}"
spaceship_ubunix() {
  [[ $SPACESHIP_UBUNIX_SHOW == false ]] && return

  [[ -z $UBUNIX ]] && return

  spaceship::section \
    "yellow" \
    "$SPACESHIP_UBUNIX_PREFIX" \
    "$SPACESHIP_UBUNIX_SYMBOL" \
    "$SPACESHIP_UBUNIX_SUFFIX"
}


# nix shell spaceship prompt
SPACESHIP_NIXSHELL_SHOW="${SPACESHIP_NIXSHELL_SHOW=true}"
SPACESHIP_NIXSHELL_PREFIX="${SPACESHIP_NIXSHELL_PREFIX="Nix-Shell "}"
SPACESHIP_NIXSHELL_SUFFIX="${SPACESHIP_NIXSHELL_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_NIXSHELL_SYMBOL="${SPACESHIP_NIXSHELL_SYMBOL="$IN_NIX_SHELL "}"
spaceship_nixshell() {
  [[ $SPACESHIP_NIXSHELL_SHOW == false ]] && return

  [[ -z $IN_NIX_SHELL ]] && return

  spaceship::section \
    "yellow" \
    "$SPACESHIP_NIXSHELL_PREFIX" \
    "$SPACESHIP_NIXSHELL_SYMBOL" \
    "$SPACESHIP_NIXSHELL_SUFFIX"
}

ZSH_AUTOSUGGEST_STRATEGY=(history)

# needed for bind2maps
typeset -A key
key=(
Home     "${terminfo[khome]}"
End      "${terminfo[kend]}"
Insert   "${terminfo[kich1]}"
Delete   "${terminfo[kdch1]}"
Backspace "^?"
Up       "${terminfo[kcuu1]}"
Down     "${terminfo[kcud1]}"
Left     "${terminfo[kcub1]}"
Right    "${terminfo[kcuf1]}"
PageUp   "${terminfo[kpp]}"
PageDown "${terminfo[knp]}"
BackTab  "${terminfo[kcbt]}"
)


fry bell-on-precmd
fry completion
fry ncserve
fry alias-usage-analysis
fry print-expanded-alias
# fry vim-open-files-at-lines
fry search-select-edit
fry git-select-commit
fry git-onstage
fry github-clone
fry interactive-mv
fry cd-tmp
fry cd-git-root
fry mkdir-cd
fry screencapture
fry transcode-video
fry bind2maps
fry git-dirty-files-command
fry watchdo
fry nvim-rpc

setopt nonomatch # avoid the zsh "no matches found" / allows sbt ~compile
setopt hash_list_all # rehash command path and completions on completion attempt
setopt transient_rprompt # hide earlier rprompts
unsetopt flow_control # we dont want no flow control, Ctrl-s / Ctrl-q, this allows vim to map <C-s>
stty -ixon # (belongs to flow control option)
autoload -U zmv # renaming utils

# activate vi modes and display mode indicator in prompt
source ~/.zshrc.vimode
RPROMPT='${MODE_INDICATOR}'

bind2maps emacs viins vicmd -- -s '^[[1;5C' forward-word
bind2maps emacs viins vicmd -- -s '^[[1;5D' backward-word

autoload edit-command-line
zle -N edit-command-line
bind2maps vicmd viins -- -s '^v' edit-command-line

autoload bashcompinit && bashcompinit

# history prefix search
autoload -U history-search-end # have the cursor placed at the end of the line once you have selected your desired command
# zle -N history-beginning-search-backward-end history-search-end
# zle -N history-beginning-search-forward-end history-search-end
# bind2maps emacs viins vicmd -- "Up" history-substring-search-up
# bind2maps emacs viins vicmd -- "Down" history-substring-search-down

bind2maps emacs viins vicmd -- "Up" up-line-or-search
bind2maps emacs viins vicmd -- "Down" down-line-or-search

# if [ -n "${commands[fzf-share]}" ]; then
#     source "$(fzf-share)/key-bindings.zsh"
#     source "$(fzf-share)/completion.zsh"
# fi

source ~/.sh_aliases

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

[ -f ~/projects/ubunix/ubunix.sh ] && source ~/projects/ubunix/ubunix.sh

if [ -n "${commands[br]}" ]; then
source /home/felix/.config/broot/launcher/bash/br
fi

