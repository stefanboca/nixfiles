function fish_jj_prompt
    if not command -sq jj
        return 1
    end

    set -l info "$(jj log 2>/dev/null --no-graph --ignore-working-copy --at-operation=@ --color=always --revisions=@ --template shell_prompt)"
    or return 1

    if test -n "$info"
        echo -n " "$info
    end
end
