## My dotfiles
my dotfiles managed with chezmoi

### [**Looking for Just Dotfile Configs and Tools?**](#looking-for-just-dotfile-configs-and-tools-1)

## My setup
| what             | I use                                                    | 
| ---------------- | -------------------------------------------------------- |
| Operating System | Window 11, WSL2 (Debian)                                 |
| Shell            | ZSH ([zsh4human](https://github.com/romkatv/zsh4humans)) |
| dotfile manager  | [chezmoi](https://www.chezmoi.io/)                       |
| editor           | neovim or vim or vi                                      |
| password manager | Bitwarden                                                |
| etc.             | there a lot                                              |

- [Prerequisite](#prerequisite)
  - [Bitwarden Vault Data](#bitwarden-vault-data) 
    - [notes](#notes) 
  - [Window Setup (skip if not use WSL2)](#window-setup-skip-if-not-using-wsl2) 
    - [Tools](#tools)
- [Installation](#installation)
- [install by branch](#installation-by-branch)
- [Updating your dotfiles](#updating-your-dotfiles)
- [Looking for Just Dotfile Configs and Tools?](#looking-for-just-dotfile-configs-and-tools-1)
- [troubleshooting](#troubleshooting)
  - [WSL2 cant execute window binary](#wsl2-cant-execute-window-binary)

## Prerequisite

- Linux or WSL2 etc.
- ensure you can run window binary [fix here](#wsl2-cant-execute-window-binary)
- bitwarden data (keep sensitive files, only main branch)
- curl 

Make sure you have curl installed. If not, you can install it with the following command:
```shell
sudo apt install -y curl
```

### Bitwarden Vault Data

To keep sensitive files away from the public repository, I use Bitwarden for added security. The following secrets are utilized within this setup.

If you don't use Bitwarden, just ignore any prompts during initialization with Chezmoi. [see.](#looking-for-just-dotfile-configs-and-tools-1)

#### notes

| name                       | contain          |
| -------------------------- | ---------------- |
| dotfiles/.ssh/config_hosts | ssh host configs |

### Window Setup (skip if not using WSL2)

Install Debian distribution or any you like

Open PowerShell or Windows Command Prompt in **administrator** mode and run.

```powershell
wsl --install -d Debian
```

#### Tools

Install with [Choco](#choco) or [Winget](#winget)

Tools list
- window terminal
- vscode
- putty

##### Choco
Install chocolatey see https://chocolatey.org/install

Open PowerShell as **Administrator** and run the following command:
```powershell
choco.exe install -y microsoft-windows-terminal vscode putty
```

##### Winget

```powershell
winget install -e --id Microsoft.WindowsTerminal
winget install -e --id Microsoft.VisualStudioCode 
winget install -e --id PuTTY.PuTTY
```

---
## Installation

To install chezmoi and clone the dotfiles in `$HOME` directory , use the bootstrap command below. 

```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply karnzx 
```

Optional variables so you can create for anyone who forks or clones these dotfiles for himself, leave it empty for manualy add

| key             | value               | 
| --------------- | ------------------- |
| BITWARDEN_EMAIL | bitwarden email     |

The command works as follows:

- Installs `chezmoi`, initializes it, and applies the dotfiles.
- Once the dotfiles are cloned, chezmoi will run scripts to install all necessary things in .chezmoiscripts directory, such as WSL2 configuration, fonts, tools, etc.
- apply chezmoi template, such as bitwarden get credential files

## Updating your dotfiles
To update your dotfiles on any machine, use the following command (assuming cz is your chezmoi alias):

```shell
cz update
```

---
## Looking for Just Dotfile Configs and Tools?
Are you looking for only dotfiles configs and tools without any secret files download from bitwarden? We've got you covered!

when installing there a prompt ark to install bitwarden, putty. just hit `Enter`

--- 

## troubleshooting

### WSL2 cant execute window binary

can not run `cmd.exe` or window program etc.
```shell
sudo sh -c 'echo :WSLInterop:M::MZ::/init:PF > /usr/lib/binfmt.d/WSLInterop.conf'
```
**Interop Issue: unable to find interpreter for launching Windows .exe files using Interop**
```shell
sudo update-binfmts --disable cli
```

then run following command on powershell
```poweshell
wsl.exe --shutdown
```
