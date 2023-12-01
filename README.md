# hc-aras-sandbox

A sandbox for Aras development with useful scripts

## Summary/Purpose

During my years of working as consultant of the Aras Innovator PLM application, I have been working different implementations, processes and environments.  
This project aims to collect and consolidate some of the generic parts, mostly the (powershell) scripts to handle incremental updates - but not exclusively.  
The project will be target the latest public(free) available release of Aras Innovator, currently 2023.

## Features

- Extracting the incremental changes from git
- Creating a deploy package for an increment

## Sub pages

[Git cheat sheet](./docs/git_cheat_sheet.md)
[Using git in Aras customization development](./docs/git_and_aras.md)

## Troubleshooting

### Trouble executing powershell scripts

You might encounter issue with executing these powershell scripts, with errors like this:

``` log
.\stage_git.ps1: File ...\stage_git.ps1 cannot be loaded. The file ...deploy\stage_git.ps1 is not digitally signed. You cannot run this script on the current system. For more information about running scripts and setting execution policy, see about_Execution_Policies at https://go.microsoft.com/fwlink/?LinkID=135170.
```

#### Solution

1. Start Windows PowerShell with the "Run as Administrator" option. Only members of the Administrators group on the computer can change the execution policy.
2. Set-ExecutionPolicy RemoteSigned
