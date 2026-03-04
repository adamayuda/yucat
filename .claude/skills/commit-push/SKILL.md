---
name: commit-push
description: Quickly commit and push current changes with an auto-generated short commit message. Use this skill when the user says things like "commit and push", "save and push changes", "push my changes", "git commit push", or wants to quickly save their work to the remote repository.
---

# Commit and Push Skill

This skill automates the process of committing all current changes and pushing them to the remote repository with a concise, auto-generated commit message.

## When to Use This Skill

Trigger this skill whenever the user wants to:
- Commit and push their current work
- Save changes to the remote repository
- Quickly sync local changes with remote
- Use phrases like "commit and push", "push changes", "save to git", "sync with remote"

## Workflow

### 1. Check for Changes

First, check if there are any changes to commit:

```bash
git status --porcelain
```

If the output is empty, inform the user there are no changes to commit and stop.

### 2. Check Branch Status

Before committing, check if the current branch is up-to-date with the remote:

```bash
git fetch origin
git status
```

Look for messages like "Your branch is behind" or "have diverged". If the branch is behind or has diverged, warn the user and ask if they want to proceed:

- If behind: "Your branch is behind the remote. You may want to pull first. Proceed anyway?"
- If diverged: "Your branch has diverged from remote. You may need to merge or rebase. Proceed anyway?"

### 3. Analyze Changes

Get a summary of the changes to generate an appropriate commit message:

```bash
git status --short
git diff --stat
```

Optionally look at a brief diff to understand the nature of changes:

```bash
git diff --unified=0 | head -50
```

### 4. Generate Commit Message

Create a short (1-2 line), simple commit message based on the changes. Follow these guidelines:

**Message Format:**
- Keep it under 50 characters if possible
- Use imperative mood (e.g., "Add", "Fix", "Update", "Remove")
- Be descriptive but concise
- Focus on what changed, not why

**Examples:**
- `Update product assessment logic`
- `Fix navigation bug in cat profile`
- `Add Mixpanel tracking`
- `Update dependencies`
- `Refactor subscription service`
- `WIP: Feature implementation` (if changes are incomplete/exploratory)

**Pattern Recognition:**
- Multiple file types changed across features → "Update multiple features" or "General updates"
- Single feature changes → Mention the feature name
- Dependency changes (pubspec.yaml, package.json) → "Update dependencies"
- Configuration/build files → "Update configuration"
- Documentation only → "Update documentation"
- Test files → "Update tests"

### 5. Stage and Commit

Stage all changes and commit:

```bash
git add .
git commit -m "Your generated message here"
```

### 6. Push to Remote

Push the commit to the current branch:

```bash
git push
```

If the branch doesn't have an upstream set, use:

```bash
git push -u origin <branch-name>
```

### 7. Report Results

Inform the user of the success:
- Show the commit message used
- Show the branch it was pushed to
- Show the commit hash (short form)

Example output:
```
✓ Committed and pushed to main
  Message: Update product assessment logic
  Commit: abc123f
```

## Error Handling

**No changes to commit:**
- Message: "No changes to commit. Working directory is clean."
- Do not proceed with commit/push

**Push rejected (non-fast-forward):**
- Explain that the remote has changes not present locally
- Suggest: `git pull --rebase` or `git pull` first

**Authentication failure:**
- Suggest checking git credentials or SSH keys
- Provide relevant troubleshooting based on the error message

**Conflicts after fetch:**
- Inform user that manual intervention is needed
- Do not force push

## Customization

The skill prioritizes speed and simplicity. If the user wants more control (custom messages, selective staging, force push), guide them to use standard git commands instead.
