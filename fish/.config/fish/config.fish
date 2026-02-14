set -g fish_greeting

if status is-interactive
    starship init fish | source

    alias mv="mv -iv"
    alias cp="cp -riv"
    alias cat="bat"
    alias trans="trans -b :ru"
    alias nt="sed 's/\\\\\n/\n/g; s/\\\\\t/\t/g'"

    alias lint="golangci-lint run --new --fix ./..."

    # List Directory
    alias l='eza -lh  --icons=auto' # long list
    alias ls='eza -1   --icons=auto' # short list
    alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
    alias ld='eza -lhD --icons=auto' # long list dirs
    alias lt='eza --icons=auto --tree' # list folder as tree

    # Handy change dir shortcuts
    abbr .. 'cd ..'
    abbr ... 'cd ../..'
    abbr .3 'cd ../../..'
    abbr .4 'cd ../../../..'
    abbr .5 'cd ../../../../..'

    abbr mkdir 'mkdir -p'

    # Always mkdir a path (this doesn't inhibit functionality to make a single dir)

    # Fixes "Error opening terminal: xterm-kitty" when using the default kitty term to open some programs through ssh
    alias ssh='kitten ssh'

    alias vim="nvim"
    alias vi="nvim"
    alias v="nvim"

    alias r="ranger"

    alias v-fish="openrepo ~/.config/fish"
    alias v-hypr="openrepo ~/.config/hypr"
    alias v-conf="openrepo ~/.config/nvim"
    alias v-dot="openrepo ~/.dotfiles"
    alias v-kitty="openrepo ~/.config/kitty"

end

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

function openrepo
    cd $argv[1]

    set title $argv[2]

    if test -n "$WEZTERM_PANE"
        wezterm cli set-tab-title "$title"
    end
    nvim .
end
