swift-ntp Contributor's Guide
=================================

The project is heavily based on swift-nio, hence follows the SwiftNIO
project's conventions.

Welcome to the SwiftNIO community, and thank you for contributing!
This guide explains how to get involved.

* Issue Tracking
* Pull Requests
* Licensing

## Issue Tracking

To file a bug or feature request, use [GitHub](https://github.com/apple/swift-ntp/issues/new).

Please use the template provided while creating the issue.

## Pull Requests

To make a pull request, use [GitHub](https://github.com/apple/swift-ntp/compare).
Please use the template provided while creating the pull request.

Make sure the CI passes, and then wait for code review.

> [!IMPORTANT]
> If you plan to make substantial changes or add new features, we encourage you to first discuss them with the wider swift-nio developer community.
> You can do this by filing a [GitHub issue](https://github.com/apple/swift-ntp/issues/new)
> This will save time and increases the chance of your pull request being accepted.

### Writing a Patch

A good SwiftNIO patch is:

1. Concise, and contains as few changes as needed to achieve the end result.
2. Tested, ensuring that any tests provided failed before the patch and pass after it.
3. Documented, adding API documentation as needed to cover new functions and properties.
4. Accompanied by a great commit message, using our commit message template.

### Commit Message Template

We require that your commit messages match our template. The easiest way to do that is to get git to help you by explicitly using the template. To do that, `cd` to the root of our repository and run:

    git config commit.template dev/git.commit.template

The default policy for taking contributions is “Squash and Merge” - because of this the commit message format rule above applies to the PR rather than every commit contained within it.

### Make sure your patch works for all supported versions of Swift

The CI will do this for you, but a project maintainer must kick it off for you.  Currently all versions of Swift >= 6.0 are supported.

### Formatting

Try to keep your lines less than 120 characters long so GitHub can correctly display your changes.

SwiftNIO uses the [swift-format](https://github.com/swiftlang/swift-format) tool to bring consistency to code formatting.  There is a specific [.swift-format](./.swift-format) configuration file.  This will be checked and enforced on PRs.  Note that the check will run on the current most recent stable version target which may not match that in your own local development environment.

This command to run is:

	swift format format -irp .



## Licensing

`swift-ntp` is released under the Apache 2.0 license.
This is why we require that, by submitting a pull request, you acknowledge that you have the right to license your contribution to Apple and the community, and agree that your contribution is licensed under the Apache 2.0 license.
