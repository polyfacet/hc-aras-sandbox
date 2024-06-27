# Git Cheat Sheet for Aras Developers

While different GUI exits to git, there are cases where git GUIs does not have the features you want, or it is difficult to find/use them.  
For this reasons this document will contain some useful git commands.

- [Comparing states](#comparing-states)
  - [Comparing what changes done in develop vs. master](#comparing-what-changes-done-in-develop-vs-master)
    - [Summary log](#summary-log)
    - [Commit log](#commit-log)
    - [More detailed and prettier commit log](#more-detailed-and-prettier-commit-log)
    - [List changed (Added/Modified/Deleted) files](#list-changed-addedmodifieddeleted-files)
- [Rebasing](#rebasing)
- [View changes for specific files](#view-changes-for-specific-files)
- [Searching](#searching)
  - [Searching commit messages](#searching-commit-messages)
  - [Searching changed contents](#searching-changed-contents)
- ["Local" gitignore](#local-gitignore)
- [References](#references)

## Comparing states

As git is local and we have a few common branches we need/should be following, mainly **master** and **develop**.

``` powershell
git fetch
```

### Comparing what changes done in develop vs. master

Below we do a compare on what has change from two "gitlab" branches, origin/master..origin/develop. ({from}..{to})
These from to can be replace with any other branch names or commits like:

- origin/master..origin/env/uat (What updates are in UAT compared to Production)
- origin/develop..i/555/bom-report (My local branch changes compared with develop on gitlab)
- origin/master..64697fc (Change from production to a specific commit id)

#### Summary log

``` powershell
# Summary of changes
 git shortlog origin/master..origin/develop
 # To ignore merge commits add the flat --no-merges like
 # git shortlog --no-merges origin/master..origin/develop
```

``` bash
# Example output (with --no-merges flag)
Tomas Andersson (3):
      feat(Inventory): Draft Inventory Basics
      cr(Inventory): Adds Purchase Price to type and form
      data(Inventory): Import some example data    
```

#### Commit log

``` powershell
# Show the log of commits between main and develop (without merges and only show as one line per commit)
git log --oneline --no-merges origin/master..origin/develop
```

``` bash
# Output example
bae0636 (origin/poc/hc_inventory, poc/hc_inventory) data(Inventory): Import some example data
2abcc6b cr(Inventory): Adds Purchase Price to type and form
bcbefb0 feat(Inventory): Draft Inventory Basics
```

#### More detailed and prettier commit log

🟡 Below example require the `git l` alias set as seen in [git aliases](../scripts/git-scripts/git-aliases-and-configs.ps1)

``` powershell
# Show the log of commits between main and develop, with when and who and a little bit prettier
git l --no-merges origin/master..origin/develop
## and with the --name-status flag added list file changes with the commits like
#git l --no-merges --name-status origin/master..origin/develop
```

``` bash
# Output example
5 weeks ago data(Inventory): Import some example data Tomas Andersson  (origin/poc/hc_inventory, poc/hc_inventory) bae0636
5 weeks ago cr(Inventory): Adds Purchase Price to type and form Tomas Andersson  2abcc6b
5 weeks ago feat(Inventory): Draft Inventory Basics Tomas Andersson  bcbefb0
```

#### List changed (Added/Modified/Deleted) files

``` powershell
git log --name-status --pretty="" origin/master..origin/develop
```

**Side note:** this is what is used to stage our changes when we deploy with [script](../scripts/deploy/stage_git.ps1)

``` bash
# Output example
A       packages/hc_inventory_data/Import/HC_Inventory/INV0002 RAM Memory.xml
A       packages/hc_inventory_data/Import/HC_Inventory/INV0003 External Harddrive.xml
M       packages/update.mf
M       packages/hc_inventory/Import/Form/HC_Inventory.xml
M       packages/hc_inventory/Import/ItemType/HC_Inventory.xml
A       packages/hc_inventory/Import/CommandBarMenu/com.aras.innovator.cui_default.toc_09471F5D71FD47F0B039BB06DB2CD293.xml
A       packages/hc_inventory/Import/CommandBarMenuButton/com.aras.innovator.cui_default.toc_HC_Inventory_F9280F9FC1EF425AB72219C81687EAE0.xml
A       packages/hc_inventory/Import/CommandBarSection/HC_Inventory_TOC_Content.xml
A       packages/hc_inventory/Import/CommandBarSectionItem/1E654B3D87B04665B5C3584C22157382.xml
A       packages/hc_inventory/Import/Form/HC_Inventory.xml
A       packages/hc_inventory/Import/ItemType/HC_Inventory.xml
A       packages/hc_inventory/Import/Life Cycle Map/HC_Inventory.xml
A       packages/hc_inventory/Import/Permission/HC_Inventory.xml
A       packages/hc_inventory/Import/PresentationConfiguration/HC_Inventory_TOC_Configuration.xml
A       packages/hc_inventory/Import/Sequence/HC_Inventory.xml
A       packages/update.mf
```

Notable is that we here get duplicates, on files that has been modified more than once.  
This can be filtered with some piping

``` powershell
## In powershell
git log --name-status --pretty="" origin/master..origin/develop | Sort-Object -unique
```

``` bash
## In git bash
git log --name-status --pretty="" origin/master..origin/develop | sort | uniq
```

``` bash
# Output example
A       packages/hc_inventory/Import/CommandBarMenu/com.aras.innovator.cui_default.toc_09471F5D71FD47F0B039BB06DB2CD293.xml
A       packages/hc_inventory/Import/CommandBarMenuButton/com.aras.innovator.cui_default.toc_HC_Inventory_F9280F9FC1EF425AB72219C81687EAE0.xml
A       packages/hc_inventory/Import/CommandBarSection/HC_Inventory_TOC_Content.xml
A       packages/hc_inventory/Import/CommandBarSectionItem/1E654B3D87B04665B5C3584C22157382.xml
A       packages/hc_inventory/Import/Form/HC_Inventory.xml
A       packages/hc_inventory/Import/ItemType/HC_Inventory.xml
A       packages/hc_inventory/Import/Life Cycle Map/HC_Inventory.xml
A       packages/hc_inventory/Import/Permission/HC_Inventory.xml
A       packages/hc_inventory/Import/PresentationConfiguration/HC_Inventory_TOC_Configuration.xml
A       packages/hc_inventory/Import/Sequence/HC_Inventory.xml
A       packages/hc_inventory_data/Import/HC_Inventory/INV0002 RAM Memory.xml
A       packages/hc_inventory_data/Import/HC_Inventory/INV0003 External Harddrive.xml
A       packages/update.mf
M       packages/hc_inventory/Import/Form/HC_Inventory.xml
M       packages/hc_inventory/Import/ItemType/HC_Inventory.xml
M       packages/update.mf
```

## Rebasing

When new baseline - i.e. after production has been updated - is created, you need to (should) rebase your in-work issue-branch onto the new baseline (origin/master)  
Most of the commands below you will probably do in your preferred GUI, but rarely is the last command `git push --force-with-lease` included in the GUI

``` powershell
# Assumption, your are in your Action branch e.g. a/9999/fix-jira-integration-bug

# Switch to main branch and pull the changes

``` bash
git checkout main
git checkout pull
```

# Switch back to previous branch
``` bash
git checkout -
```

# Rebase
``` bash
git rebase main
## ❗ Note that here git conflict may arise, most likely on the myupdate.mf file
## Any conflict must first be resolved before continuing
```

# If you have previously pushed your action-branch to gitlab you should update with the rebased local branch
``` bash
git push --force-with-lease
```


```

## View changes for specific files

The base for this is "git log"

To view the changes done for a specific file:

``` bash
git log -- src/packages/PLM/Import/Method/PE_ManualRelease.xml
```

Even simpler - which also shows moved file:

``` bash
git log -- *PE_ManualRelease.xml
```

To include the changes in each change, use the patch flag:

``` bash
git log -p -- src/packages/PLM/Import/Method/PE_ManualRelease.xml
git log -p -- *PE_ManualRelease.xml
```

As I think the "log" is kind of difficult to read, I rather use an alternative alias "l" for log like:

``` bash
git l -- *PE_ManualRelease.xml
```

Set the alias with:
``` bash
git config --global alias.l "log --pretty='format:%Cblue%cr %Creset%s %Cblue%an %Cred%d %Cgreen%h'"
```

Another example:
This shows all the changed "PLM" methods that are named like "Action" and which files that were changed in each commit:

``` bash
git l --name-status -- src/packages/PLM/Import/Method/*Action*
```

## Searching

### Searching commit messages

Set the alias "find":
``` bash
git config --global alias.find "log -i --pretty=\"format:%Cgreen%h %Cred%cr %Cblue%s %Cred%an\" --name-status --grep"
```

To find commit messages having Issue-1628
``` bash
git find Issue-1628
```

### Searching changed contents

Below is two example for typically find code changes that contains "Part Document" and "team_id", i.e. item.getRelationships("Part Document") or item.setProperty("team_id")

``` bash
git log --oneline -S '"Part Document"' -i
git log --oneline -S '"team_id"'
```

-S is called the "pickaxe", and -i is used to make the search case insensitive.

## "Local" gitignore

Use case: I want to have a basic todo.txt file in the root of my project/git repo, so quickly jot down some todo-notes, but I don't want to add todo.txt to the common .gitignore. I.e. pollute it with ignores of my personal workflow.  
For this we can use the `.git/info/exclude` file. It has the same format as the common .gitignore
So just add todo.txt to the exclude file and thats it.

## References

1. [About git fetch (Atlassian)](https://www.atlassian.com/git/tutorials/syncing/git-fetch#:~:text=In%20review%2C%20git%20fetch%20is,the%20state%20of%20a%20remote.)
2. [Git Pickaxe](https://gist.github.com/phil-blain/2a1cf81a0030001d33158e44a35ceda6)
3. [Git ignore local](https://stackoverflow.com/questions/1753070/how-do-i-configure-git-to-ignore-some-files-locally)
