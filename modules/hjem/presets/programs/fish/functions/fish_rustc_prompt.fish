function fish_rustc_prompt
    command -sq rustc
    or return 1

    set -l parent_dirs (__fish_parent_directories $PWD)
    path is $parent_dirs/Cargo.toml
    or return 1

    rustc --version 2>/dev/null | string match -qr "(?<info>[\d.]+)"

    if test -n "$info"
        echo -n "  $info"
    end
end
