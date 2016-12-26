# DoggoHub Flow

----------

- A simplified branching strategy
- All features and fixes first go to master
- Allows for 'production' or 'stable' branches
- Bug fixes/hot fix patches are cherry-picked from master

----------

### Feature branches

- Create a feature/bugfix branch to do all work
- Use merge requests to merge to master

![inline](http://doggohub.com/doggohub-org/University/raw/5baea0fe222a915d0500e40747d35eb18681cdc3/training/doggohub_flow/feature_branches.png)

----------

## Production branch

- One, long-running production release branch
  as opposed to individual stable branches
- Consider creating a tag for each version that gets deployed

----------

## Production branch

![inline](http://doggohub.com/doggohub-org/University/raw/5baea0fe222a915d0500e40747d35eb18681cdc3/training/doggohub_flow/production_branch.png)

----------

## Release branch

- Useful if you release software to customers
- When preparing a new release, create stable branch
  from master
- Consider creating a tag for each version
- Cherry-pick critical bug fixes to stable branch for patch release
- Never commit bug fixes directly to stable branch

----------

![inline](http://doggohub.com/doggohub-org/University/raw/5baea0fe222a915d0500e40747d35eb18681cdc3/training/doggohub_flow/release_branches.png)

----------

## More details

Blog post on 'DoggoHub Flow' at
[http://doc.doggohub.com/ee/workflow/doggohub_flow.html](http://doc.doggohub.com/ee/workflow/doggohub_flow.html)
