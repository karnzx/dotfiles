## My dotfiles
my dotfiles managed with chezmoi

### My setup
| what             | I use                                                    | 
| ---------------- | -------------------------------------------------------- |
| Operating System | WSL2 (Debian)                                            |
| Shell            | ZSH ([zsh4human](https://github.com/romkatv/zsh4humans)) |
| dotfile manager  | [chezmoi](https://www.chezmoi.io/)                       |
| editor           | neovim or vim or vi                                      |
| password manager | Bitwarden                                                |
| etc.             | there a lot                                              |

**there different setup see [install by branch](#installation-by-branch)**

- [Prerequisite](#prerequisite)
  - [Window Setup (skip if not use WSL2)](#window-setup-skip-if-not-using-wsl2) 
    - [Tools](#tools)
- [Installation](#installation)
- [install by branch](#installation-by-branch)
- [Updating your dotfiles](#updating-your-dotfiles)
- [troubleshooting](#troubleshooting)
  - [WSL2 cant execute window binary](#wsl2-cant-execute-window-binary)

## Prerequisite

- Linux or WSL2 etc.
- ensure you can run window binary [fix here](#wsl2-cant-execute-window-binary)
- curl 

Make sure you have curl installed. If not, you can install it with the following command:
```shell
sudo apt install -y curl
```

### Window Setup (skip if not using WSL2)

Install Debian distribution or any you like

Open PowerShell or Windows Command Prompt in **administrator** mode and run.

```powershell
wsl --install -d Debian
```

#### Tools
| what                       | it is                   |
| -------------------------- | ----------------------- |
| vscode                     | the visual studio code  |
| vcxsrv                     | for diplay GUI for WSL2 |
| microsoft-windows-terminal | window terminal         | 

Install chocolatey see https://chocolatey.org/install

Open PowerShell as **Administrator** and run the following command:
```powershell
choco.exe install -y microsoft-windows-terminal vscode vcxsrv microsoft-windows-terminal
```

After installation, run XLaunch and configure it as follows:
- Click "Next" twice.
- Uncheck "Primary Selection" and click "Next".
- Save the configuration at the shell:startup path.

---
## Installation

To install chezmoi and clone the dotfiles, use the bootstrap command below. 

There are two optional variables you can create for anyone who forks or clones these dotfiles for personal use:

| key             | value               | 
| --------------- | ------------------- |
| GITHUB_USERNAME | git repo username   |
| BITWARDEN_EMAIL | bitwarden email     |

```shell
GITHUB_USERNAME=karnzx \
BITWARDEN_EMAIL=bitwarden@email.com \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/karnzx/dotfiles/main/bootstrap.sh)"
```

The `bootstrap.sh` script works as follows:

- Installs `bitwarden-cli` and unlocks the vault.
- Installs `chezmoi`, initializes it, and applies the dotfiles.
- Once the dotfiles are cloned, chezmoi will run scripts to install all necessary things, such as WSL2 configuration, fonts, tools, etc.

## installation by branch

Each branch have different setup for example.
- `config-and-tools` branch dont have `bitwarden-cli` so there no any credentail sync

Take a look at branch `README` for installation or maybe you can just add `--branch` on `chezmoi`

```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply karnzx --branch config-and-tools
```


## Updating your dotfiles
To update your dotfiles on any machine, use the following command (assuming cz is your chezmoi alias):

```shell
cz update
```
--- 

## troubleshooting

### WSL2 cant execute window binary

can not run `cmd.exe` or window program etc.
```shell
sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
```
then run following command on powershell
```poweshell
wsl.exe --shutdown
```
