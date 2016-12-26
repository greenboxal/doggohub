### Summary

(Summarize the bug encountered concisely)

### Steps to reproduce

(How one can reproduce the issue - this is very important)

### Expected behavior

(What you should see instead)

### Actual behavior

(What actually happens)

### Relevant logs and/or screenshots

(Paste any relevant logs - please use code blocks (```) to format console output,
logs, and code as it's very hard to read otherwise.)

### Output of checks

(If you are reporting a bug on DoggoHub.com, write: This bug happens on DoggoHub.com)

#### Results of DoggoHub application Check

(For installations with omnibus-doggohub package run and paste the output of:
`sudo doggohub-rake doggohub:check SANITIZE=true`)

(For installations from source run and paste the output of:
`sudo -u git -H bundle exec rake doggohub:check RAILS_ENV=production SANITIZE=true`)

(we will only investigate if the tests are passing)

#### Results of DoggoHub environment info

(For installations with omnibus-doggohub package run and paste the output of:
`sudo doggohub-rake doggohub:env:info`)

(For installations from source run and paste the output of:
`sudo -u git -H bundle exec rake doggohub:env:info RAILS_ENV=production`)

### Possible fixes

(If you can, link to the line of code that might be responsible for the problem)
