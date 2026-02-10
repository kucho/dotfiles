function zr --description 'Open a folder on r0n1n via Zed SSH remote' --argument path
    if test -z "$path"
        set path (pwd)
    end

    if not string match -q '/*' -- $path
        set path "$HOME/$path"
    end

    set path (string replace "$HOME" "~" -- $path)
    set path (string replace -r '^/' '' -- $path)

    zed "ssh://r0n1n/$path"
end
