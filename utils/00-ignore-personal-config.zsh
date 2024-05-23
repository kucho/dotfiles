#!/bin/zsh
project_path=$(realpath "$0" | sed -E 's|(/[^/]+/dotfiles)/.*|\1|')

files_to_ignore=(
	"git/.git_config/.personal/.gitconfig-local"
	"wsl2/.config/.gpg/.gitconfig-os-specific-local"
)

current_ignored_files=()

missing_ignored_files=()

while IFS= read -r line; do
	current_ignored_files+=("${line:2}")
done < <(git -C $project_path ls-files -v | grep "^[[:lower:]]")

for file_to_ignore in "${files_to_ignore[@]}"; do
    if [[ ! " ${current_ignored_files[@]} " =~ " ${file_to_ignore#$project_path} " ]]; then
        missing_ignored_files+=("$file_to_ignore")
    fi
done

for file_path in "${missing_ignored_files[@]}"; do
	git update-index --assume-unchanged "$project_path/$file_path"
done
