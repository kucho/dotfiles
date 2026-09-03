function listening --description 'Check listening ports' --argument pattern
    switch (uname)
        case Darwin
            set -l cmd "sudo lsof -iTCP -sTCP:LISTEN -n -P"
        case '*'
            set -l cmd "ss -tlnp"
    end

    if test -z "$pattern"
        eval $cmd
    else
        eval $cmd | grep -i --color $pattern
    end
end
