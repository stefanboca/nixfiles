function fish_prompt
    set -l last_status $status

    set -l suffix '❯'
    set -l color_suffix green
    set -l color_cwd $fish_color_cwd

    if not contains $last_status 0
        set color_suffix $fish_color_status
    end

    if functions -q fish_is_root_user; and fish_is_root_user
        set -q fish_color_cwd_root && set color_cwd $fish_color_cwd_root
        set suffix '#'
    end

    set -l vcs_prompt (eval echo '$'$__fish_async_prompt'[1]')

    echo -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd --dir-length 0) (set_color green) $vcs_prompt
    echo -n -s (set_color $color_suffix) $suffix" "
end
