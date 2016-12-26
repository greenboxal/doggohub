# Visibility and access controls

## Enabled Git access protocols

> [Introduced][ce-4696] in DoggoHub 8.10.

With DoggoHub's Access restrictions you can choose which Git access protocols you
want your users to use to communicate with DoggoHub. This feature can be enabled
via the `Application Settings` in the Admin interface.

The setting is called `Enabled Git access protocols`, and it gives you the option
to choose between:

- Both SSH and HTTP(S)
- Only SSH
- Only HTTP(s)

![Settings Overview](img/access_restrictions.png)

When both SSH and HTTP(S) are enabled, DoggoHub will behave as usual, it will give
your users the option to choose which protocol they would like to use.

When you choose to allow only one of the protocols, a couple of things will happen:

- The project page will only show the allowed protocol's URL, with no option to
  change it.
- A tooltip will be shown when you hover over the URL's protocol, if an action
  on the user's part is required, e.g. adding an SSH key, or setting a password.

![Project URL with SSH only access](img/restricted_url.png)

On top of these UI restrictions, DoggoHub will deny all Git actions on the protocol
not selected.

> **Note:** Please keep in mind that disabling an access protocol does not actually
  block access to the server itself. The ports used for the protocol, be it SSH or
  HTTP, will still be accessible. What DoggoHub does is restrict access on the
  application level.

[ce-4696]: https://doggohub.com/doggohub-org/doggohub-ce/merge_requests/4696
