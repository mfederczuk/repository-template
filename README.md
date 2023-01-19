<!--
  Copyright (c) 2023 Michael Federczuk
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Repository Template #

## About ##

<!-- TODO: rewrite -->

This is a generic repository template, containing:

* All community standard files recommended by **GitHub**:
  * [README](template/README.md)
  * [Code of conduct](template/CODE_OF_CONDUCT.md)
  * [Contributing](template/CONTRIBUTING.md)
  * [License](template/COPYING.txt)
  * [Issue templates](template/.github/ISSUE_TEMPLATE)
  * [Pull request template](template/.github/pull_request_template.md)
* [Development Guidelines](template/DEVELOPING.md)
* [`.editorconfig` file](template/.editorconfig)

The actual template files are located in the [`template`](template) directory and contain template variables in the form
of `{{VARIABLE_NAME}}` that must be replaced with actual values.

The [`use`](use) script helps setting up a new project by copying the template to a chosen location, prompting for
*some* of the variables and replacing these variables with the given values.  
To use the script, make sure that you have [jq] installed.

The [`webget.bash`](webget.bash) script automatically clones this repository, prompts for a target and then runs
the `use` script:

```sh
curl -L 'https://github.com/mfederczuk/repository-template/raw/master/webget.bash' | bash
```

```sh
wget -O- 'https://github.com/mfederczuk/repository-template/raw/master/webget.bash' | bash
```

[jq]: <https://github.com/stedolan/jq> "stedolan/jq: Command-line JSON processor"

## License ##

Generally, this template is published into the public domain under [**CC0**](LICENSES/CC0-1.0.txt), though different
licenses apply for individual files.  
For more information about copying and licensing, see the [`COPYING.txt`](COPYING.txt) file.
