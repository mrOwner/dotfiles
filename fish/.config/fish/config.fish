set -g fish_greeting

if status is-interactive
    starship init fish | source
end

alias mv="mv -iv"
alias cp="cp -riv"
alias cat="bat"
alias trans="trans -b :ru"
alias nt="sed 's/\\\\\n/\n/g; s/\\\\\t/\t/g'"

alias lint="golangci-lint run --new --fix ./..."

# List Directory
alias ls="lsd"
alias l="ls -lt --date relative"
alias la="ls -a --date date"
alias ll="ls -l --date date"
alias lla="ls -la --date date"
alias lt="ls --tree"

# Handy change dir shortcuts
abbr .. 'cd ..'
abbr ... 'cd ../..'
abbr .3 'cd ../../..'
abbr .4 'cd ../../../..'
abbr .5 'cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
abbr mkdir 'mkdir -vp'

# Fixes "Error opening terminal: xterm-kitty" when using the default kitty term to open some programs through ssh
alias ssh='kitten ssh'

alias vim="nvim"
alias vi="nvim"
alias v="nvim"

alias v-fish="nvim ~/.config/fish/config.fish"
alias v-hypr="nvim ~/.config/hypr"
alias v-conf="nvim ~/.config/nvim"
alias v-dot="nvim ~/.dotfiles"
alias v-kitty="nvim ~/.config/kitty/kitty.conf"

set -gx EDITOR nvim
set -gx GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin

function renamebranch -d "Переименовывает текущую ветку в git"
    set -l cb (git branch --show-current)
    git branch -m $argv &&
        git push origin -u $argv # &&
    # git push origin -d $cb
end


function kill-by-port -d "Ебашит приложение по занятому порту"
    if test (count $argv) -eq 0
        echo "Не указан порт"
        return 1
    end

    set pid (lsof -i :$argv[1] | awk '{if(NR>1) print $2}')

    if test -n "$pid"
        kill -SIGTERM $pid
        echo "Процесс с PID $pid убит 🥲"
    else
        echo "На порту $argv[1] нет активных процессов"
    end
end
