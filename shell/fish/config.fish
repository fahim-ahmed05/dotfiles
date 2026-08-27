# Only run this stuff in interactive sessions
if status is-interactive
    set -g fish_greeting ""  # no greeting, keep it clean

    # One Dark Pro–style colors
    set -g fish_color_normal          normal
    set -g fish_color_command         '#61AFEF'   # blue
    set -g fish_color_param           '#ABB2BF'   # foreground
    set -g fish_color_quote           '#98C379'   # green
    set -g fish_color_redirection     '#56B6C2'   # cyan
    set -g fish_color_end             '#56B6C2'
    set -g fish_color_error           '#E06C75'   # red
    set -g fish_color_comment         '#5C6370'   # comments
    set -g fish_color_operator        '#56B6C2'
    set -g fish_color_escape          '#C678DD'   # purple
    set -g fish_color_autosuggestion  '#4B5263'   # dim but readable
    set -g fish_color_selection       --background='#3E4451'



    # --------------------------------------------------
    # Aliases for common commands
    # --------------------------------------------------
    # eza as ls/ll/la
    if type -q eza
        alias ls="eza"
        alias ll="eza -l -h --icons --git --group-directories-first"
        alias la="eza -la -h --icons --git --group-directories-first"
    else
        # Fallback to regular ls if eza is not installed
        alias ll="ls -lh"
        alias la="ls -lha"
    end

    # fzf
    if type -q fzf
        alias ff="fzf"
    end

    # --------------------------------------------------
    # zoxide for quick directory navigation
    # --------------------------------------------------
    if type -q zoxide
        zoxide init fish --cmd cd | source
        alias z="cd"
    end

    # --------------------------------------------------
    # fzf keybindings & completion 
    # --------------------------------------------------
    if test -f /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
    end

    if test -f /usr/share/fzf/completion.fish
        source /usr/share/fzf/completion.fish
    end

    # --------------------------------------------------
    # Functions 
    # --------------------------------------------------

    # mkcd: make directory and cd into it
    function mkcd
        if test (count $argv) -eq 0
            echo "Usage: mkcd <directory>"
            return 1
        end

        set dir $argv[1]
        mkdir -p -- $dir
        cd $dir
    end
end
