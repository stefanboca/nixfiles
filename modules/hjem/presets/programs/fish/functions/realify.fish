function realify --description="Replace symlink(s) with real file(s) in‑place"
    for file in $argv
        if test -L "$file"
            command cp --remove-destination (readlink -f "$file") "$file"
            chmod +w "$file"
        else
            echo "realify: $file is not a symlink" >&2
        end
    end
end
