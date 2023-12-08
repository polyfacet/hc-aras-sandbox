# This configuration will make pull commands rebase instead of merge:
git config --global pull.rebase true

# This configuration adds extra colors when running git diff to show blocks of lines that remain unchanged but have moved in the file.
git config --global diff.colorMoved zebra

# Logs "functional" changes. If conventional commits are applied, this filters out the changes
# that matters most from and end user perspective. Commit messages starting with feat/fix/cr/perf
# Use like "git rl master..HEAD | sort" to 
git config --global alias.rl "log --pretty=\"%s%\" master..HEAD --grep='^cr\|^feat\|^fix\|^perf'"

# commit with add and message
git config --global alias.cm 'commit -am'

# Status short with branch name
git config --global alias.s "status -sb"

# A condensed/pretty log
git config --global alias.l "log --pretty=\"format:%Cblue%cr %Creset%s %Cblue%an %Cred%d %Cgreen%h\""

# The a condensed pretty Log of All Branches (including remotes)
# Useful to get a glance on what others are working with
git config --global alias.lab "l --branches=* --remotes=* --graph"

# Search commit messages
git config --global alias.find "log -i --pretty=\"format:%Cgreen%h %Cred%cr %Cblue%s %Cred%an\" --name-status --grep"
#Use: git find PLM-1628

# Run mergetodev when you are working with a "issue-branch"
# Rebases it against a pulled dev/main and then merges into dev/main
# When doing these we avoid merge commits, and get a straight development history line in dev/main 
git config --local alias.mergetodev "!git checkout dev/main && git pull && git checkout - && git rebase dev/main && git checkout - && git status -sb && git merge - && :"