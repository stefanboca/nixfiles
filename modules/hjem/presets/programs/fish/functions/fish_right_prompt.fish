function fish_right_prompt
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    test $__fish_prompt_status_generation = $status_generation && set bold_flag
    set __fish_prompt_status_generation $status_generation
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "" "" "|" "" "$statusb_color" $last_pipestatus)

    set -q IN_NIX_SHELL && set -l nix_shell "  $IN_NIX_SHELL"

    set -l rustc_version (eval echo '$'$__fish_async_prompt'[2]')

    if test $CMD_DURATION -gt 100
        set -l hours (math -s0 "$CMD_DURATION / 3_600_000")
        set -l minutes (math -s0 "$CMD_DURATION / 60_000 % 60")
        set -l seconds (math -s1 "$CMD_DURATION / 1_000 % 60")

        if test $hours != 0
            set -f command_duration $hours" "$minutes"m "$seconds"s"
        else if test $minutes != 0
            set -f command_duration $minutes"m "$seconds"s"
        else
            set -f command_duration $seconds"s"
        end
        set command_duration "  "$command_duration
    end

    echo -n -s $prompt_status (set_color yellow) $command_duration (set_color red) $rustc_version (set_color blue) $nix_shell (set_color green) " "(date +%T)
end
