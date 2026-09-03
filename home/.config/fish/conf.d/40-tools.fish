if command -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end

command -q fnox; and fnox activate fish | source
command -q starship; and starship init fish | source
