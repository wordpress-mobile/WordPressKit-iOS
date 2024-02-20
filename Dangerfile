# frozen_string_literal: true

github.dismiss_out_of_range_messages

# `files: []` forces rubocop to scan all files, not just the ones modified in the PR
rubocop.lint(files: [], force_exclusion: true, inline_comment: true, fail_on_inline_comment: true, include_cop_names: true)

manifest_pr_checker.check_all_manifest_lock_updated

podfile_checker.check_podfile_does_not_have_branch_references

pr_size_checker.check_diff_size(
  max_size: 300,
  type: :insertions
)
