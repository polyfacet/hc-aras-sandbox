# Working with git and Aras

Working with development and Version Control Systems (VCS) (here: git) can be done in a lot of different ways. There exist a few common philosophies regarding this. In this context, we are working with an Aras customization, which means that we have just a handful of installations to consider - basically only one or two "live" versions ("Production" and "Development") - and only a few **concurrent** developers. Compare this to the Linux kernel which have a massive amount of contributors (14000+) and installations to consider.

An emphasis on concurrent is made, because this relates to the importance of [conventional commits](#convectional-commits) and [commit practices](#commit-practices).
As it is almost a nature law that, software that does not get updated/maintained dies. It is of extremely importance to keep the software maintainable. We want to minimize the dependency on a specific developer/maintainer(s) having a good git history/documentation mitigates this risk of "lock ins". One way to mitigate this is to use conventional commits, as mentioned in [Why use conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#why-use-conventional-commits)

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Git Basics](#git-basics)
- [Commit practices](#commit-practices)
  - [Side notes on commit messages and suggestion](#side-notes-on-commit-messages-and-suggestion)
  - [Convectional commit types](#convectional-commit-types)
- [Beyond the basics](#beyond-the-basics)
  - ["Reviewing" the changes](#reviewing-the-changes)
  - [myupdate.mf vs. imports.mf](#myupdatemf-vs-importsmf)
- [Suggested branch handling and workflow](#suggested-branch-handling-and-workflow)
  - [Background](#background)
    - [Alternative approach to merge request](#alternative-approach-to-merge-request)
  - [Description of simplified change workflow](#description-of-simplified-change-workflow)
- [References](#references)

## Git Basics

Git is a command line based tool - which comes with basic Graphical User Interfaces (GUI) git-gui. Git has an immense amount of features/commands with flags and options. Learning git can feel like a daunting task. The good thing is that you may not need to - but when working with it daily you will probably want to. Why would I, you may ask. The reason is that there exists a [multitude of GUIs for git](https://git-scm.com/download/gui/windows) which all basically serves as a frontend to the command line. As there exist so many you might choose one of your liking to start with ( I personally use both the command line and the built in GUI in [VS Code](https://code.visualstudio.com/) together with the Git Graph extension, which is seen in the screenshots further down ). Later down the road you may get to a point where you want to do a specific thing with this in git, which is not possible in your preferred GUI or the GUI can do it, but it has some twists. Using the command line you will be in better control on whats going on.

There exits so many different GUIs - which evolve or die. It is not feasible to write documentation depending on a specific UI. Git on the other hand is very solid piece of software, which was invented by Linus Torvalds (creator of Linux) and initially developed by Linus and some other Linux developers, to have Version Control System (VCS) that fitted the needs for developing Linux. With this as a background an the fact this is todays de facto standard VCS, widely adapted.

## Commit practices

Writing good commit messages and content of a commit is a valuable thing which can be read about at many places, so I will not linger too much on it, but provide a few links/articles on the topic.

- [The Importance of Good Commit Messages](https://levelup.gitconnected.com/the-importance-of-good-commit-messages-9331251e5e33)
- [From the Odin Project](https://www.theodinproject.com/lessons/foundations-commit-messages)

I do want to emphasis on "The Newspaper metaphor" (From the book Clean Code by Robert C. Martin aka "Uncle Bob" ) While the book covers writing code, it is also applicable for commit messages or any system documentation. In summary: Have the most important things first.
Quoted from the book:

> Think of a well-written newspaper article. You read it vertically. At the top you expect a headline that will tell you what the story is about and allows you to decide whether it is something you want to read. The first paragraph gives you the synopsis of the whole story, hiding all the details while giving you the broad-brush concepts. As you continue downward, the details increase until you have the dates, names, quotes, claims and other minutia.

With this in mind - and conventional commits, see below - a good commit message would be look something like:

> cr(Part): Allows users to delete a new Part
>
> The users had access to do delete the Part, but it was used in an Part Commercial Name.
> This Part Commercial Name, will now be implicitly deleted before the deletion of the Part
>
> ref: Issue-555

The first row is the title, the "body" provides some details about the implementation and finally a reference to the Issue, where perhaps more information can be found. You will have all the technical details of the change in that commit.

### Side notes on commit messages and suggestion

An adjustment to this convention could maybe be, to include the Issue reference in the title like:

> cr(Part): Allows users to delete a new Part (Issue-555)

Since I know how bad/careless people generally are at writing documentation.
My experience is however that it is not the content of an issue (normally a Jira Issue) that provides the information you need when investigating a change. The case is all to often to get information about who where involved in the issue. I.e. had the "requirements"/intents of it. As the specifications in the issues are not trustworthy, because the specification may have changed during the development or at some other point in time. But no one bothered to update the specification, because the change was agreed in "fire camp"-meeting. So you will need to find the information stored in some carbon-based hard drive.

### Convectional commit types

Conventional commits are one way to make the git history better.
[Why use conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#why-use-conventgional-commits)
Below is a suggested start for which "types" to use in our commits.

- cr: Change Request
- feat: A new feature
- fix: A bug fix
- perf: A code change that improves performance
- refactor: A code change that neither fixes a bug nor adds a feature
- ootb: A commit that adds "original" files or configurations from Production environment, that is to be changed in the subsequent commit. (So the changes get tracked)
- docs: Documentation only changes
- deploy: Changes to our CI configuration files and scripts
- build: Changes that affect the build system or external dependencies
- style: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- test: Adding missing tests or correcting existing tests
- cleanup: Removes superfluous things like: commented out code, unused stuff (e.g. PostSystemUpdate code, which has been executed and will not be used again)

## Beyond the basics

Git has many features, some that could be useful are described here with some other related in depth notes.

### "Reviewing" the changes

The git log contains a lot of information, which can be used in various ways.
One way could be to get a quick summary of changes by author. This is an easy way to see who’s been working on what.
`git shortlog --since=2023-06-01 --no-merges > june-work-2023-06-28.log`

See [git cheat sheet](./git_cheat_sheet.md) for more examples.

### myupdate.mf vs. imports.mf

While myupdate.mf is basically the same thing as the standard imports.mf file generated by exports, there is difference.  
The difference is that is intended for updates - not necessarily for complete package imports.  
This means that dependencies may vary from imports.mf. Using an update of the PLM-package as an example below, the exported imports.mf looks something like this:

``` xml

  <package name="com.aras.innovator.solution.PLM" path="PLM\Import">
    <dependson name="com.xplm.aras.CAD" />
    <dependson name="com.aras.innovator.core" />
    <dependson name="com.aras.innovator.solution.ApplicationCore" />
    <dependson name="com.aras.innovator.conversion" />
  </package>
```

The com.aras.innovator.core dependency comes from the PLM out of the box package, this is a "new" package dependency. I.e. it is there to ensure, that it exist before adding the PLM package for the first time to database.  
com.xplm.aras.CAD on the other hand is not an Aras Corp. package, and has been added as "build dependency". com.xplm.aras.CAD have methods/actions etcetera, that are added to the (PLM) CAD item type for instance, which require them to be imported first. Before the update of the CAD item type is updated.
These methods does however depend on PLM in order to be functional - unlike the core package.  
Having this understanding we do not necessarily need to have the same setup in myupdate.mf.  
As we don't need the "new" packages dependencies, we can remove the com.aras.innovator* dependson here.

As a side note. I don't know about the other none standard packages, but sometimes circular dependencies can be introduced. In those cases the dependson does not work, and the way to solve it is to run without the explicit dependson and put the packages in the order the imports should be executed.

## Suggested branch handling and workflow

### Background

Working with `merge requests` is probably the most common way to work with change management of code. It is worth to notice that this basically required for open source project where you will have "untrusted" contributors. Here on the other hand we have a small "trusted" **team**. An emphasis on team, as good collaborative team makes every team member better an subsequently the code/application better.  
My experience is that `merge requests` are inefficient. Why?  

- Because the "reviews" often becomes bottlenecks/slow.
- The feedback from the review is "too late"
- Increased risk of git conflicts, which is difficult for the reviewer to resolve

Let me elaborate. If we have a trivial fix/improvement in a Form, e.g. changing a label, and another change that will add a new field to the same Form. This will either create a conflict for the reviewer to resolve or wait for the first merge request to be approved. The first alternative introduces a risk and the other is inefficient.  
Normally, when you submit a merge request, you will let it go and start working on the next task. When the reviewer has time - maybe a week later - to review the merge request and discuss it/give feedback on it you may be in full focus on solving another task. And also as mentioned dropped the thought about the old task. This breaks the focus of your current task and you need to recap on the old task. As the merge request stack up, the context switching escalate with it.  
The "too late" issue, is that when you get the feedback, it may be on the general design of the solution. This may result in that you need to make a greater re-write of the solution. So there is risk of waste time/energy there.  

An article which has a lengthier elaboration can be found [here](https://medium.com/@ErikGebers/is-the-best-branching-strategy-no-branches-at-all-5cd7774d863b), if you want some more meat on the issue.

#### Alternative approach to merge request

So what is the alternative to merge requests?  
I would suggest a hybrid model. A model that mixes [trunk based development](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development), a lightweight [pair programming](https://en.wikipedia.org/wiki/Pair_programming) and [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) (for hotfixes).  
It may sound complicated, but the purpose is to [keep it simple](https://en.wikipedia.org/wiki/KISS_principle).
In short, it is an agile approach, to handle changes differently depending on the context.
With this approach the dev/main branch and the common development will represent the "truth/latest and greatest". And when you reach the end of a development cycle - or any time during the cycle - it is easy to merge/update User Acceptance Test (UAT) environment with the "latest and greatest".  
To use the same examples as mentioned above. The context is important.  
The change of the label in the Form, just commit/sync the change directly to dev/main, it is a trivial change.  
If a change is complicated/not straight forward or being a "junior" developer, make a preemptive peer review early on, discuss a drafted solution via an "Issue" branch with another developer. This is what I mean by lightweight pair programming. We will have the benefits of mitigate the risk of a bad design decision, get an early review when the developer is fully focused on the task and knowledge spreading.  
And in the case where something bad is committed to the dev/main branch, there are a few ways to solve it - which again depends on the context.

1. Fix it
2. Revert the change. (Typically if it is only changes to Method(s))
3. Use feature toggling (<https://en.wikipedia.org/wiki/Feature_toggle> also part of trunk based development)
4. Rebase dev/main and drop the bad commits and "restore" dev DB (Worst case scenario)

Where I have work with this approach, when something "bad is solved" it i about option 1. in 97%, 2. in 2% and 3. 1% of the cases.

### Description of simplified change workflow

As we are basically maintain one single installation, i.e. a production environment, we can "mirror" our installations in git. By having the **master** branch mirror the production environment and **dev/main** branch mirror the development environment(s), everyone having access to this repo will know what is implemented in each environment.

It is a recommendation to use "issue branches" for developing change request, like i/2763/echa-error-code (implements change request Issue-2763). This will ensure that commits to that branch will/should contain "2763" in each commit message (if [prepare-commit-msg](../scripts/git-scripts/prepare-commit-msg) has been copied to .git/hooks), tieing the change to the Issue.

When finished, alias "git mergetodev" ([some git aliases](../scripts/git-scripts/git-aliases-and-configs.ps1)) can be used, to rebase and merge into dev/main.


## References

1. [Conventional Commits Org](https://www.conventionalcommits.org)
2. [YOUTUBE: Dave Farley - Continuous Integration vs Feature Branch Workflow](https://www.youtube.com/watch?v=v4Ijkq6Myfc)
3. [Installing VS Code on windows](https://code.visualstudio.com/docs/setup/windows)
4. [On Rebasing (Atlassian)](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)
5. [Trunk based development](https://trunkbaseddevelopment.com)
6. [No branching article](https://medium.com/@ErikGebers/is-the-best-branching-strategy-no-branches-at-all-5cd7774d863b)
