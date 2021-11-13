# Repository Template #

## About ##

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

The [`webget.bash`] script automatically clones this repository, prompts for a target and then runs the `use` script:

```sh
curl 'https://raw.githubusercontent.com/mfederczuk/repository-template/master/webget.bash' | bash
```

[`webget.bash`]: https://github.com/mfederczuk/repository-template/blob/master/webget.bash

## License ##

This template is licensed under the [**Unlicense**](LICENSES/Unlicense.txt).  
For more information about copying and licensing, see the [COPYING.txt](COPYING.txt) file.
