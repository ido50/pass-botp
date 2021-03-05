#!/bin/bash

[[ $# -ne 1 ]] && [[ $# -ne 2 ]] && die "Usage: $PROGRAM $COMMAND [--clip,-c] pass-name"

if [[ $1 = "-c" ]] || [[ $1 = "--clip"  ]]; then
    clip=1
    path="$2"
elif [[ $2 = "-c" ]] || [[ $2 = "--clip"  ]]; then
    clip=1
    path="$1"
else
    clip=0
    path="$1"
fi

passfile="$PREFIX/$path.gpg"
check_sneaky_paths "$path"
set_gpg_recipients "$(dirname "$path")"
set_git "$passfile"

if [[ -f $passfile ]]; then
    file_contents=$($GPG -d "${GPG_OPTS[@]}" "$passfile")

    botp=false
    backup_code=""

    while IFS= read -r line; do
        if [[ $line =~ ^botp: ]]; then
            botp=true
            continue
        fi

        if [ "$botp" = true ]; then
            if [[ $line =~ ^# ]]; then
                # already used code, continue
                continue
            else
                # unused code
                backup_code="${line/#    /}"
                break
            fi
        fi
    done <<< "$file_contents"

    if [[ -z "$backup_code" ]]; then
        die "Unable to get backup code"
    fi

    updated_file_contents=${file_contents/    $backup_code/    \# $backup_code}

    if [[ $clip -eq 0 ]]; then
        echo "$backup_code"
    else
        clip "$backup_code" "Backup code for $path"
    fi

    $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" <<< "$updated_file_contents"

    git_add_file "$passfile" "Used backup code for $path."
elif [[ -z $path ]]; then
    die ""
else
    die "Error: $path is not in the password store."
fi
