function zed --description 'Open Zed, or zeditor on Linux packages that use that name'
    if command -q zed
        command zed $argv
    else if command -q zeditor
        command zeditor $argv
    else
        echo "zed: command not found" >&2
        return 127
    end
end
