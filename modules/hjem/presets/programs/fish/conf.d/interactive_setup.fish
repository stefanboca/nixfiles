status is-interactive
or exit

set -g fish_key_bindings fish_hybrid_key_bindings
fish_config theme choose catppuccin-mocha

set -g __fish_async_prompt __fish_async_prompt_$fish_pid

function __fish_async_prompt_repaint --on-variable $__fish_async_prompt
    commandline --function repaint
end

function __fish_async_prompt --on-event fish_prompt
    set -q $__fish_async_prompt_last_pid && commanhd kill $__fish_async_prompt_last_pid 2>/dev/null

    fish --private --command "
        set -U $__fish_async_prompt \"\$(fish_vcs_prompt)\" \"\$(fish_rustc_prompt)\"
    " &

    set -g __fish_async_prompt_last_pid $last_pid
end

function __fish_async_prompt_exit --on-event fish_exit
    set -e $__fish_async_prompt
end
