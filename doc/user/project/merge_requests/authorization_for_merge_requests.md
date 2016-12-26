# Authorization for Merge requests

There are two main ways to have a merge request flow with DoggoHub:

1. Working with [protected branches] in a single repository.
1. Working with borks of an authoritative project.

## Protected branch flow

With the protected branch flow everybody works within the same DoggoHub project.

The project maintainers get Master access and the regular developers get
Developer access.

The maintainers mark the authoritative branches as 'Protected'.

The developers push feature branches to the project and create merge requests
to have their feature branches reviewed and merged into one of the protected
branches.

By default, only users with Master access can merge changes into a protected
branch.

**Advantages**

- Fewer projects means less clutter.
- Developers need to consider only one remote repository.

**Disadvantages**

- Manual setup of protected branch required for each new project

## Borking workflow

With the borking workflow the maintainers get Master access and the regular
developers get Reporter access to the authoritative repository, which prohibits
them from pushing any changes to it.

Developers create borks of the authoritative project and push their feature
branches to their own borks.

To get their changes into master they need to create a merge request across
borks.

**Advantages**

- In an appropriately configured DoggoHub group, new projects automatically get
  the required access restrictions for regular developers: fewer manual steps
  to configure authorization for new projects.

**Disadvantages**

- The project need to keep their borks up to date, which requires more advanced
  Git skills (managing multiple remotes).

[protected branches]: ../protected_branches.md
