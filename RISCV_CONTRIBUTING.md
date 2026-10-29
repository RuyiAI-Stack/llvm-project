# Contributing to riscv across base branch rebases

## Background

The `riscv` branch in `RuyiAI-Stack/llvm-project` follows LLVM upstream through rebases and force-pushes. Rebasing changes the SHAs of replayed commits. A development branch created from an older version of `riscv` can therefore have different commit history even when its inherited patches are unchanged.

As a result, a PR may show duplicate historical commits, unrelated file changes, or merge conflicts. This is divergent history, rather than corrupted code or SHAs. The goal is to keep each PR focused on its actual contribution and align it with the latest `riscv` before merging.

The following two approaches support different collaboration needs.

## Option 1: Agree on an issue and contribute to a maintainer-created branch

Start each work item with an issue. After approval, submit PRs to the branch designated by a maintainer. The maintainer integrates the completed work into `riscv`.

### Procedure

1. **Open an issue.** Describe the goal, implementation scope, dependencies, and validation plan. Use an existing issue when it already covers the work.
2. **Obtain maintainer agreement.** Confirm the direction, owner, collaborators, and expected integration scope.
3. **The maintainer creates a work branch.** Create it from the current `riscv`, for example `work/issue-123`, and record its name and starting commit in the issue.
4. **Submit PRs to the designated branch.** Set the base repository to `RuyiAI-Stack/llvm-project` and the base branch to `work/issue-123`. Contributors can submit from their forks without direct write access to the target repository.
5. **Develop and review on the work branch.** Submit related PRs to this branch. The maintainer reviews, tests, and merges them. Keep the work branch history stable during development; notify collaborators before rewriting it.
6. **The maintainer integrates the completed work into riscv.** Identify the actual new commits, align them with the latest `riscv`, resolve conflicts, and rerun tests. Use an integration PR for final review and merging. Close the issue and remove the work branch after integration is confirmed.

Example:

```text
Agree on an issue
  -> Maintainer creates work/issue-123
  -> Contributors submit PRs to work/issue-123
  -> Review, merge, and test in stages
  -> Maintainer aligns the completed work with the latest riscv
  -> Merge the integration PR into riscv
```

### Branch maintenance

- When `riscv` follows upstream, contributors do not all need to rewrite their development history immediately. The maintainer coordinates when to update the work branch.
- The work branch must still be aligned with the latest `riscv` before integration. Merging its old base history directly can bring back duplicate history or outdated changes.
- This approach centralizes integration work and provides a stable collaboration base. Conflicts may still need resolution during final integration.
- Before merging into `riscv`, the maintainer verifies that the final diff contains only the intended changes and completes the relevant tests.

## Option 2: Submit directly to riscv and manually run the automatic rebase workflow

Submit a PR directly to `riscv`. When the base branch changes, manually trigger the workflow to rebase and force-push the PR source branch onto the latest `riscv`.

The workflow automates rebasing, conflict resolution, and pushing. It runs only when manually triggered, has no scheduled runs, and does not merge PRs. **Each run updates the source branch immediately after a successful rebase and validation; there is no preview option.** An already-current PR requires no push.

### Procedure

1. **Open a PR.** Target `RuyiAI-Stack/llvm-project:riscv` from the contributor's development branch.
2. **Install the workflow.** Add [autorebase.yml](.github/workflows/autorebase.yml) to the PR source repository's default branch at `.github/workflows/autorebase.yml`, and enable GitHub Actions.
3. **Run the workflow.** In the source repository, open **Actions -> Manually rebase PR onto riscv -> Run workflow**. Select a branch containing the YAML, enter the PR number from the target repository, and run it. The workflow rebases the PR and updates its source branch using `--force-with-lease` with an explicit expected SHA.
4. **Check the result.** Inspect the Actions result, remaining commit count, and conflict resolution report. Review the updated PR diff to confirm that the required functionality is preserved.
5. **Test and review.** Complete the relevant builds, tests, and review before a maintainer merges the PR.

### Repository and permissions

The workflow must run in the **PR source repository**, because it updates the PR source branch.

| PR type | Workflow repository | Branch updated |
| --- | --- | --- |
| PR from a fork, such as #33 | `OurCompArchGroup/llvm-project` | `ruyi-llvm24` |
| PR from the same repository, such as #34 | `RuyiAI-Stack/llvm-project` | `test` |

The workflow uses the automatically provided `GITHUB_TOKEN`. Do not create that secret manually; no `AUTOREBASE_TOKEN` is needed. The YAML requests `contents: write`. Repository and organization policies must allow the required access, and source branch rules must permit force-pushes.

The target repository's `GITHUB_TOKEN` does not grant write access to a fork. For a fork PR, the author or an authorized collaborator runs the workflow in the source repository.

### Rebase and conflict rules

- **Use the latest riscv as the base.** Fetch the current base branch and PR head rather than assuming old SHAs remain valid.
- **Skip patch-equivalent historical commits.** Git rebase normally skips equivalent patches already present in the base. Commits that become empty during replay are also dropped. Patches that have since changed may not be recognized as equivalent, so inspect the final diff.
- **Resolve all conflicts in favor of the riscv side.** Use `git rebase --strategy=ort -Xours` for conflicting content. Resolve remaining conflicts using the rebase's ours side as well, including preserving deletions on that side.
- **Keep nonconflicting PR changes.** The preference applies to conflicts; it does not replace the entire PR with `riscv`.
- **Protect concurrent work.** Recheck the PR state, source branch, and base before pushing. Use the recorded source SHA as an explicit force-push lease. If the author updates the source during execution, refuse to overwrite it and rerun against the latest state.
- **Leave riscv and merging to the maintainer.** Update only the validated PR source branch. Never rewrite the `riscv` base branch or merge a PR automatically.

During rebase, `ours` means the latest `riscv` plus PR commits already replayed. PR changes that conflict with this side may be discarded. Review the combined result when PR commits depend on each other. If conflict resolution removes required functionality, adapt the implementation on the updated branch and submit it for review again.

The workflow does not build or execute PR code. Pushes made with `GITHUB_TOKEN` normally do not trigger subsequent push or PR workflows. Verify that CI checks apply to the updated SHA and use the project's manual CI entry point when needed.

After the workflow force-pushes, contributors must also synchronize their local development branch. Save uncommitted work and unpushed commits before aligning with the updated remote branch, and avoid pushing the old base history back.
