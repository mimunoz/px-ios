fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### create_version

```sh
[bundle exec] fastlane create_version
```

Start here, create a version from develop or release branch

### start_deploy

```sh
[bundle exec] fastlane start_deploy
```

Start here, this lane goes through the different ones

### deploy_lib

```sh
[bundle exec] fastlane deploy_lib
```

Deploy to Github And CocoaPods

### deploy_public

```sh
[bundle exec] fastlane deploy_public
```

Publish public lib

### deploy_private

```sh
[bundle exec] fastlane deploy_private
```

Publish private lib

### pr_check

```sh
[bundle exec] fastlane pr_check
```



### integration_tests

```sh
[bundle exec] fastlane integration_tests
```



### build_example_local

```sh
[bundle exec] fastlane build_example_local
```



### communicate_build_to_slack

```sh
[bundle exec] fastlane communicate_build_to_slack
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
