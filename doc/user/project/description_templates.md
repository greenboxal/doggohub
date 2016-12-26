# Description templates

>[Introduced][ce-4981] in DoggoHub 8.11.

Description templates allow you to define context-specific templates for issue
and merge request description fields for your project.

## Overview

By using the description templates, users that create a new issue or merge
request can select a description template to help them communicate with other
contributors effectively.

Every DoggoHub project can define its own set of description templates as they
are added to the root directory of a DoggoHub project's repository.

Description templates must be written in [Markdown](../markdown.md) and stored
in your project's repository under a directory named `.doggohub`. Only the
templates of the default branch will be taken into account.

## Creating issue templates

Create a new Markdown (`.md`) file inside the `.doggohub/issue_templates/`
directory in your repository. Commit and push to your default branch.

## Creating merge request templates

Similarly to issue templates, create a new Markdown (`.md`) file inside the
`.doggohub/merge_request_templates/` directory in your repository. Commit and
push to your default branch.

## Using the templates

Let's take for example that you've created the file `.doggohub/issue_templates/Bug.md`.
This will enable the `Bug` dropdown option when creating or editing issues. When
`Bug` is selected, the content from the `Bug.md` template file will be copied
to the issue description field. The 'Reset template' button will discard any
changes you made after picking the template and return it to its initial status.

![Description templates](img/description_templates.png)

[ce-4981]: https://doggohub.com/doggohub-org/doggohub-ce/merge_requests/4981
