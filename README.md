## My dotfiles
my dotfiles managed with chezmoi

### My setup
| what             | I use                                                    | 
| ---------------- | -------------------------------------------------------- |
| Operating System | WSL2 (Debian)                                            |
| Shell            | ZSH ([zsh4human](https://github.com/romkatv/zsh4humans)) |
| dotfile manager  | [chezmoi](https://www.chezmoi.io/)                       |
| editor           | neovim or vim or vi                                      |
| etc.             | there a lot                                              |

- [Prerequisite](#prerequisite)
  - [Window Setup (skip if not use WSL2)](#window-setup-wsl2) 
    - [Tools](#tools)
- [Installation](#installation)

## Prerequisite

- Linux or WSL2 etc.
- curl
- ensure you can run window binary 

```shell
sudo apt install -y curl
```

### Window Setup (WSL2)
**(skip if not use WSL2)**

Install Debian distribution or any you like

Open PowerShell or Windows Command Prompt in **administrator** mode and run.

```powershell
wsl --install -d Debian
```
#### Tools
| what   | it is                   | 
| ------ | ----------------------- |
| vscode | the visual studio code  |
| vcxsrv | for diplay GUI for WSL2 |

Install chocolatey see https://chocolatey.org/install

Open PowerShell as **Administrator** and run:
```powershell
choco.exe install -y microsoft-windows-terminal vscode vcxsrv 
```
run XLaunch > Next > Next > Uncheck Primary Selection, Next > Save Config at `win+r` > `shell:startup` path

---
## Installation


install chezmoi and clone dotfiles.

once clone dotfiles chezmoi will install all necessary things such as WSL2 config, fonts, tools etc.
```shell
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply karnzx
```

Updating your dotfiles on any machine is a single command:

`cz` is chezmoi alias
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
then `wsl.exe --shutdown` in powershell
