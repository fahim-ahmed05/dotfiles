function fish_prompt
    # Last command status
    set -l last_status $status

    # One Dark prompt colors
    set -l color_dir   '#61AFEF'   # blue for path
    set -l color_git   '#C678DD'   # purple for branch
    set -l color_error '#E06C75'   # red for errors
    set -l color_symbol '#ABB2BF'  # arrow color

    # Blank line before each prompt (clean look)
    echo

    # Current directory
    set_color $color_dir
    printf '%s' (prompt_pwd)

    # Git branch (simple)
    set -l git_branch (command git rev-parse --abbrev-ref HEAD 2>/dev/null)

    if test -n "$git_branch"
        printf ' '
        set_color $color_git
        #  is the branch symbol (looks best with a Nerd Font like JetBrainsMono NF)
        printf ' %s' $git_branch
    end

    # Error indicator if last command failed
    if test $last_status -ne 0
        set_color $color_error
        printf ' ✗'
    end

    # New line + arrow prompt
    set_color $color_symbol
    echo
    printf '❯ '
    set_color normal
end
