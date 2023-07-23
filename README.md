## My dotfiles
my dotfiles managed with chezmoi

## **Need Only dotfiles configs and tools?** 
see [config-and-tools branch](https://github.com/karnzx/dotfiles/tree/config-and-tools)

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
  - [Bitwarden data](#bitwarden-data) 
    - [notes](#notes) 
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
- bitwarden data (keep sensitive files, only main branch)
- curl 

Make sure you have curl installed. If not, you can install it with the following command:
```shell
sudo apt install -y curl
```

### Bitwarden data

for keep sensitive file away from public repo

#### notes

| name                 | contain          |
| -------------------- | ---------------- |
| dotfiles/.ssh/config | ssh host configs |

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
| microsoft-windows-terminal | window terminal         | 

Install chocolatey see https://chocolatey.org/install

Open PowerShell as **Administrator** and run the following command:
```powershell
choco.exe install -y microsoft-windows-terminal vscode 
```

---
## Installation

To install chezmoi and clone the dotfiles, use the bootstrap command below. 

Optional variables so you can create for anyone who forks or clones these dotfiles for himself

| key             | value               | 
| --------------- | ------------------- |
| BITWARDEN_EMAIL | bitwarden email     |

```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply karnzx 
```

The command works as follows:

- Installs `chezmoi`, initializes it, and applies the dotfiles.
- Once the dotfiles are cloned, chezmoi will run scripts to install all necessary things in .chezmoiscripts directory, such as WSL2 configuration, fonts, tools, etc.
- apply chezmoi template, such as bitwarden get credential files

## installation by branch

Each branch have different setup for example.
- [config-and-tools](https://github.com/karnzx/dotfiles/tree/config-and-tools) contain only configs and tools. no password manger (bitwarden-cli)

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
