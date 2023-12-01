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
🔴
```

#### Commit log

``` powershell
# Show the log of commits between main and develop (without merges and only show as one line per commit)
git log --oneline --no-merges origin/master..origin/develop
```

``` bash
# Output example
🔴
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
🔴
```

#### List changed (Added/Modified/Deleted) files

``` powershell
git log --name-status --pretty="" origin/master..origin/develop
```

**Side note:** this is what is used to stage our changes when we deploy with [script](../scripts/deploy/stage_git.ps1)

``` bash
# Output example
🔴
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
🔴
```

## Rebasing

When new baseline - i.e. after production has been updated - is created, you need to (should) rebase your in-work issue-branch onto the new baseline (origin/master)  
Most of the commands below you will probably do in your preferred GUI, but rarely is the last command `git push --force-with-lease` included in the GUI

``` powershell
# Assumption, your are in your Action branch e.g. a/9999/fix-jira-integration-bug

# Switch to main branch and pull the changes
git checkout main
git checkout pull

# Switch back to previous branch
git checkout -

# Rebase
git rebase main
## ❗ Note that here git conflict may arise, most likely on the myupdate.mf file
## Any conflict must first be resolved before continuing

# If you have previously pushed your action-branch to gitlab you should update with the rebased local branch
git push --force-with-lease


```


## References

1. [About git fetch (Atlassian)](https://www.atlassian.com/git/tutorials/syncing/git-fetch#:~:text=In%20review%2C%20git%20fetch%20is,the%20state%20of%20a%20remote.)