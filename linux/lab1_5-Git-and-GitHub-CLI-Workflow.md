# Lab 1.5 — Git and GitHub CLI Workflow

## Environment

Platform: Windows laptop  
Terminal: Command Prompt  
Repository: cloud-engineering-foundations  
Local folder name: linux-filesystem-labs  
Branch: main


## Goals

- Understand Git concepts under GitHub Desktop
- Install and configure Git for command line use
- Practice checking repository status
- View commit history
- Create a file from the terminal
- Stage changes
- Commit changes
- Push commits to GitHub
- Delete a tracked file
- Commit and push cleanup
- Confirm the repo is clean


## Git Setup

Git was installed on Windows using Git for Windows.

Important setup choices:

```text
Default editor: Notepad++ / available editor
Default branch name: main
PATH option: Git from the command line and also from third-party software
SSH executable: bundled OpenSSH
HTTPS backend: Windows Secure Channel
Line endings: checkout Windows-style, commit Unix-style
Terminal emulator: MinTTY / Git Bash default
Pull behavior: fast-forward or merge
```

Understanding:

```text
Git = version control engine
GitHub Desktop = visual interface for Git
GitHub.com = online remote repository
Command Prompt / Git Bash = terminal interface for Git commands
```


## Core Git Mental Model

```text
Working directory = files as they currently exist on the laptop
Staging area     = files selected for the next commit
Commit history   = saved checkpoints
Remote/origin    = GitHub copy of the repository
Push             = send local commits to GitHub
Pull             = bring GitHub commits down locally
```

Workflow:

```text
Working directory
→ git add
→ Staging area
→ git commit
→ Local commit history
→ git push
→ GitHub remote
```


## Checking Repository State — `git status`

Command:

```bash
git status
```

Purpose:

Show the current state of the repository.

It shows:

```text
current branch
whether branch is synced with origin/main
changed files
untracked files
staged files
clean working tree
```

Initial observed result:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Understanding:

```text
Local repository is clean
No uncommitted changes
Laptop and GitHub are synced
```

Mental Model:

```text
git status = what changed?
```

GitHub Desktop equivalent:

```text
Changes tab
```


## Viewing Commit History — `git log --oneline`

Command:

```bash
git log --oneline
```

Purpose:

Show commit history in compact form.

Observed:

```text
64ac1a9 Add Lab 1.4 networking tools documentation
6ee3a40 Update repository README for cloud engineering roadmap
ae72a42 Move processes, services, and system state notes into linux folder
```

Understanding:

Each line contains:

```text
commit ID + commit message
```

Important Example:

```text
64ac1a9 (HEAD -> main, origin/main, origin/HEAD)
```

Meaning:

```text
HEAD -> main = local branch points here
origin/main = GitHub remote branch points here
origin/HEAD = GitHub default branch points here
```

If all point to the same commit:

```text
local repo and GitHub are synced
```

Mental Model:

```text
git log --oneline = compact commit history
```

GitHub Desktop equivalent:

```text
History tab
```


## Creating a Practice File

Command:

```bash
echo Git CLI practice complete > git-cli-practice.txt
```

Purpose:

Create a test file from the command line.

Understanding:

```text
echo = print/write text
>    = redirect output into file and overwrite/create file
```

Created file:

```text
git-cli-practice.txt
```


## Checking New File State

Command:

```bash
git status
```

Observed:

```text
Untracked files:
  git-cli-practice.txt
```

Understanding:

Git sees the file, but it is not tracking it yet.

Meaning:

```text
The file exists in the working directory
but is not staged for commit
```

Mental Model:

```text
untracked = Git sees it, but it has not been added yet
```


## Staging a File — `git add`

Command:

```bash
git add git-cli-practice.txt
```

Purpose:

Stage the file for commit.

Understanding:

```text
git add = select file for the next commit
```

After staging:

```bash
git status
```

Observed:

```text
Changes to be committed:
  new file: git-cli-practice.txt
```

Meaning:

```text
The file moved from working directory/untracked
to the staging area
```

Mental Model:

```text
git add = prepare this change for checkpoint
```


## Creating a Commit — `git commit`

Command:

```bash
git commit -m "Practice Git CLI Workflow"
```

Purpose:

Save staged changes as a checkpoint in Git history.

Observed:

```text
[main e62f763] Practice Git CLI Workflow
1 file changed, 1 insertion(+)
create mode 100644 git-cli-practice.txt
```

Understanding:

```text
A new local commit was created
The practice file was added to Git history
```

Breakdown:

```text
git commit = create checkpoint
-m         = message
"..."      = commit message
```

Mental Model:

```text
git commit = save staged work into Git history
```

GitHub Desktop equivalent:

```text
Commit to main
```


## Local Branch Ahead of GitHub

Command:

```bash
git status
```

Observed after local commit:

```text
Your branch is ahead of 'origin/main' by 1 commit.
```

Understanding:

```text
The laptop has one commit that GitHub does not have yet
```

Meaning:

```text
local repo is ahead of remote repo
```

Next step:

```text
push the commit to GitHub
```


## Pushing to GitHub — `git push`

Incorrect command tried:

```bash
git push origin/main
```

Observed error:

```text
fatal: 'origin/main' does not appear to be a git repository
```

Understanding:

Git interpreted `origin/main` as one remote name, which was incorrect.

Correct command:

```bash
git push origin main
```

Breakdown:

```text
git push = upload commits
origin   = remote GitHub repository
main     = branch
```

Observed:

```text
To https://github.com/Dorian-Freeman/cloud-engineering-foundations.git
64ac1a9..e62f763 main -> main
```

Understanding:

```text
The local commit was pushed to GitHub
GitHub now has the new commit
```

Mental Model:

```text
git push = laptop → GitHub
```

GitHub Desktop equivalent:

```text
Push origin
```


## Confirming Sync After Push

Command:

```bash
git status
```

Observed:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Understanding:

```text
Laptop and GitHub are synced
No uncommitted changes
Working tree is clean
```


## Verifying Latest Commit

Command:

```bash
git log --oneline
```

Observed top line:

```text
e62f763 (HEAD -> main, origin/main, origin/HEAD) Practice Git CLI Workflow
```

Understanding:

```text
The latest local commit
the main branch
and GitHub remote branch
all point to the same commit
```

This confirms the push worked.


## Cleaning Up Practice File

Because the practice file was only for learning, it was deleted to keep the repository clean.

Command:

```bash
del git-cli-practice.txt
```

Purpose:

Delete the practice file from the working directory.

Then the deletion was staged:

```bash
git add git-cli-practice.txt
```

Understanding:

```text
Deleted files must also be staged
so Git knows the deletion should be committed
```


## Committing the Deletion

Command:

```bash
git commit -m "Git CLI practice file"
```

Observed:

```text
1 file changed, 1 deletion(-)
delete mode 100644 git-cli-practice.txt
```

Understanding:

```text
The file deletion was saved as a new commit
```

Important concept:

```text
Git tracks file creation and file deletion
```


## Pushing the Cleanup Commit

Command:

```bash
git push origin main
```

Observed:

```text
e62f763..710114e main -> main
```

Understanding:

```text
Cleanup commit was pushed to GitHub
```


## Final Repo Check

Command:

```bash
git status
```

Observed:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Understanding:

```text
Repository is clean
Laptop and GitHub are synced
No changes remain
```

Command:

```bash
git diff
```

Observed:

```text
No output
```

Understanding:

```text
There are no unstaged differences
```

Mental Model:

```text
No output from git diff = nothing currently changed
```


## Full Git CLI Workflow Practiced

```text
git status
→ check repo state

git log --oneline
→ view compact commit history

echo ... > file.txt
→ create a file

git status
→ see untracked file

git add file.txt
→ stage file

git commit -m "message"
→ create local checkpoint

git status
→ see branch ahead of origin/main

git push origin main
→ upload commit to GitHub

git status
→ confirm synced clean state

del file.txt
→ delete practice file

git add file.txt
→ stage deletion

git commit -m "message"
→ commit deletion

git push origin main
→ push cleanup

git diff
→ verify no unstaged changes
```


## GitHub Desktop Connection

GitHub Desktop actions and Git CLI equivalents:

```text
Changes tab        = git status
File diff view     = git diff
Commit to main     = git commit
Push origin        = git push origin main
Pull origin        = git pull origin main
History tab        = git log
```

Understanding:

```text
GitHub Desktop is the visual steering wheel
Git CLI is the engine underneath
GitHub.com is the online remote copy
```


## Key Commands Learned

```bash
git status
git log --oneline
git add <file>
git add .
git commit -m "message"
git push origin main
git pull origin main
git diff
```


## Important Lessons

### Local folder name vs GitHub repo name

The local laptop folder can have a different name than the GitHub repository.

Example:

```text
Local folder: linux-filesystem-labs
GitHub repo: cloud-engineering-foundations
```

This can work, but it may become confusing.

Important:

```text
Git tracks the repository based on its .git folder and remote URL,
not just the folder name.
```


### Correct push syntax

Incorrect:

```bash
git push origin/main
```

Correct:

```bash
git push origin main
```

Why:

```text
origin = remote
main   = branch
```


### Clean working tree

A clean final state looks like:

```text
nothing to commit, working tree clean
```

Meaning:

```text
No uncommitted changes
Repository is clean
```


## Cloud Engineering Connection

Git matters for cloud engineering because infrastructure work needs version control.

Examples:

```text
Terraform files
Ansible playbooks
Bash scripts
Python automation
Cloud architecture notes
Documentation
Kubernetes YAML
CI/CD pipeline files
```

Git helps track:

```text
what changed
who changed it
when it changed
why it changed
how to roll back
```

In cloud and DevOps environments:

```text
If it is not in Git, it is hard to trust, review, automate, or recover.
```


## Reflection

Biggest Concepts Learned:

- Git is the version control engine
- GitHub Desktop is a visual tool for Git
- GitHub.com is the remote repository
- `git status` shows current repo state
- `git log --oneline` shows compact commit history
- `git add` stages changes
- `git commit` creates a checkpoint
- `git push` sends commits to GitHub
- `git diff` shows exact unstaged changes
- A clean working tree means no local changes remain
- Commit history is part of the technical portfolio

Key Learning Pattern:

```text
Check
→ Change
→ Stage
→ Commit
→ Push
→ Verify
```