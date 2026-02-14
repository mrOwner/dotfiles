set -g fish_greeting

set -gx EDITOR (which nvim)
set -gx GOPATH $HOME/go
set -gx NVM_DIR $HOME/.nvm
set -gx CGO_ENABLED true

set -x fish_user_paths
fish_add_path ~/.cargo/bin
fish_add_path ~/.mvn
fish_add_path $GOPATH/bin

bind \ep "clear; echo (get-clipboard) | jaq | nt"

fnm env --use-on-cd | source

if status is-interactive
    starship init fish | source

    abbr cp "cp -riv"
    abbr find fd
    abbr jq jaq

    alias mv="mv -iv"
    alias cat="bat"
    alias trans="trans -b :ru"
    alias mkdir="mkdir -vp"
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

    alias nodejs-11 "fmn use 11"
    alias nodejs-18 "fmn use 18"
    alias nodejs-24 "fmn use 24"
end

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

function set-clipboard
    if test (uname) = Darwin
        # macOS
        if not test -t 0
            cat | pbcopy
        else
            echo $argv | pbcopy
        end
    else
        # Linux
        if type -q wl-copy
            if not test -t 0
                cat | wl-copy
            else
                echo $argv | wl-copy
            end
        else if type -q xclip
            if not test -t 0
                cat | xclip -selection clipboard
            else
                echo $argv | xclip -selection clipboard
            end
        else if type -q xsel
            if not test -t 0
                cat | xsel --clipboard --input
            else
                echo $argv | xsel --clipboard --input
            end
        else
            echo "No clipboard utility found!" >&2
            return 1
        end
    end
end

function get-clipboard
    if test (uname) = Darwin
        pbpaste
    else
        if type -q wl-paste
            wl-paste
        else if type -q xclip
            xclip -selection clipboard -o
        else if type -q xsel
            xsel --clipboard --output
        else
            echo "No clipboard utility found!" >&2
            return 1
        end
    end
end
