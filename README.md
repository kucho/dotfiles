<h2 align="center">kucho/dotfiles</h2>

## Prerequisites
1. [GNU/Stow](https://www.gnu.org/software/stow/)

##  Installation

1. Clone onto your machine:
  ```bash
  git clone git@github.com:kucho/dotfiles.git ~/dotfiles
  ```

2. Setup personal credentials:
  ```bash
  # git/.git_config/.personal/.gitconfig-local
  [user]
    name = My Username
    email = My Email
    signingkey = My Signingkey
  ```

  - <details>
      <summary>For WSL2 only</summary>

      ```bash
      # wsl2/.config/.gpg/.gitconfig-os-specific-local
      [gpg "ssh"]
        # replace MyUser for your machine user
        program = "/mnt/c/Users/MyUser/AppData/Local/1Password/app/8/op-ssh-sign-wsl"
      ```
    </details>

  - Finally run:
    ```bash
    # This will untrack our personal credentials
    ./utils/00-ignore-personal-config.zsh
    ```

3. Install the configuration files you need/want:
  ```bash
  cd ~/dotfiles
  stow zsh
  stow git
  stow osx
  ```

4. Edit/Replace/Create new config files and restow them:
  ```bash
  stow -R zsh # the folder that contains the new config file
  ```

## Known issues

<details>
  <summary><b>WSL2</b></summary>


- If you're getting `"warning: Empty last update token."` it is due to `fsmonitor` is `true` at the `git/.gitconfig` file. There is two solucions for that
    - The not recommended one is to simple set it as `false`
    - The second one is to upgrade the `git version` because it was solved at `2.36.1` so to upgrade it is as simple as:
    ```bash
    git --version # it must be >= 2.36.1
    # if not let's upgrade git
    sudo add-apt-repository ppa:git-core/ppa
    sudo apt update && sudo apt upgrade -y
    ```
</details>