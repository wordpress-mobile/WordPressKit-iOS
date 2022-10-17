# frozen_string_literal: true

swiftlint.config_file = '.swiftlint.yml'

# This doesn't work on Linux, because the binary is build for macOS
#
# swiftlint.binary_path = './Pods/SwiftLint/swiftlint'
#
# Without it, the tool should install SwiftLint by itself, and hopefully in the
# right architecture.

# By default, Danger won't fail but that's not what we want.
# With `strict`, Danger will fail on warning and errors.
# Alternatively pass `fail_on_errors: true` to `lint_files`, although that only fails on errors, which is not as good.
swiftlint.strict = true
swiftlint.lint_files inline_mode: true
