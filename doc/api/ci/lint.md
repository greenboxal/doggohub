# Validate the .doggohub-ci.yml

> [Introduced][ce-5953] in DoggoHub 8.12.

Checks if your .doggohub-ci.yml file is valid.

```
POST ci/lint
```

| Attribute  | Type    | Required | Description |
| ---------- | ------- | -------- | -------- |
| `content`  | string    | yes      | the .doggohub-ci.yaml content|

```bash
curl --header "Content-Type: application/json" https://doggohub.example.com/api/v3/ci/lint --data '{"content": "{ \"image\": \"ruby:2.1\", \"services\": [\"postgres\"], \"before_script\": [\"gem install bundler\", \"bundle install\", \"bundle exec rake db:create\"], \"variables\": {\"DB_NAME\": \"postgres\"}, \"types\": [\"test\", \"deploy\", \"notify\"], \"rspec\": { \"script\": \"rake spec\", \"tags\": [\"ruby\", \"postgres\"], \"only\": [\"branches\"]}}"}'
```

Be sure to copy paste the exact contents of `.doggohub-ci.yml` as YAML is very picky about indentation and spaces.

Example responses:

* Valid content:

    ```json
    {
      "status": "valid",
      "errors": []
    }
    ```

* Invalid content:

    ```json
    {
      "status": "invalid",
      "errors": [
        "variables config should be a hash of key value pairs"
      ]
    }
    ```

* Without the content attribute:

    ```json
    {
      "error": "content is missing"
    }
    ```
