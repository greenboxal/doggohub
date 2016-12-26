# Issue closing pattern

>**Note:**
This is the administration documentation.
There is a separate [user documentation] on issue closing pattern.

When a commit or merge request resolves one or more issues, it is possible to
automatically have these issues closed when the commit or merge request lands
in the project's default branch.

## Change the issue closing pattern

In order to change the pattern you need to have access to the server that DoggoHub
is installed on.

The default pattern can be located in [doggohub.yml.example] under the
"Automatic issue closing" section.

> **Tip:**
You are advised to use http://rubular.com to test the issue closing pattern.
Because Rubular doesn't understand `%{issue_ref}`, you can replace this by
`#\d+` when testing your patterns, which matches only local issue references like `#123`.

**For Omnibus installations**

1. Open `/etc/doggohub/doggohub.rb` with your editor.
1. Change the value of `doggohub_rails['issue_closing_pattern']` to a regular
   expression of your liking:

    ```ruby
    doggohub_rails['issue_closing_pattern'] = "((?:[Cc]los(?:e[sd]|ing)|[Ff]ix(?:e[sd]|ing)?) +(?:(?:issues? +)?%{issue_ref}(?:(?:, *| +and +)?))+)"
    ```
1. [Reconfigure] DoggoHub for the changes to take effect.

**For installations from source**

1. Open `doggohub.yml` with your editor.
1. Change the value of `issue_closing_pattern`:

    ```yaml
    issue_closing_pattern: "((?:[Cc]los(?:e[sd]|ing)|[Ff]ix(?:e[sd]|ing)?) +(?:(?:issues? +)?%{issue_ref}(?:(?:, *| +and +)?))+)"
    ```

1. [Restart] DoggoHub for the changes to take effect.

[doggohub.yml.example]: https://doggohub.com/doggohub-org/doggohub-ce/blob/master/config/doggohub.yml.example
[reconfigure]: restart_doggohub.md#omnibus-doggohub-reconfigure
[restart]: restart_doggohub.md#installations-from-source
[user documentation]: ../user/project/issues/automatic_issue_closing.md
