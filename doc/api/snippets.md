# Snippets

> [Introduced][ce-6373] in DoggoHub 8.15.

### Snippet visibility level

Snippets in DoggoHub can be either private, internal, or public.
You can set it with the `visibility_level` field in the snippet.

Constants for snippet visibility levels are:

| Visibility | Visibility level | Description |
| ---------- | ---------------- | ----------- |
| Private    | `0`  | The snippet is visible only to the snippet creator |
| Internal   | `10` | The snippet is visible for any logged in user |
| Public     | `20` | The snippet can be accessed without any authentication |

## List snippets

Get a list of current user's snippets.

```
GET /snippets
```

## Single snippet

Get a single snippet.

```
GET /snippets/:id
```

Parameters:

| Attribute          | Type    | Required | Description                   |
| ---------          | ----    | -------- | -----------                   |
| `id`               | Integer | yes      | The ID of a snippet           |

``` bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://doggohub.example.com/api/v3/snippets/1
```

Example response:

``` json
{
  "id": 1,
  "title": "test",
  "file_name": "add.rb",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "web_url": "http://example.com/snippets/1",
}
```

## Create new snippet

Creates a new snippet. The user must have permission to create new snippets.

```
POST /snippets
```

Parameters:

| Attribute          | Type    | Required | Description                |
| ---------          | ----    | -------- | -----------                |
| `title`            | String  | yes      | The title of a snippet     |
| `file_name`        | String  | yes      | The name of a snippet file |
| `content`          | String  | yes      | The content of a snippet   |
| `visibility_level` | Integer | yes      | The snippet's visibility   |


``` bash
curl --request POST --data '{"title": "This is a snippet", "content": "Hello world", "file_name": "test.txt", "visibility_level": 10 }' --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://doggohub.example.com/api/v3/snippets
```

Example response:

``` json
{
  "id": 1,
  "title": "This is a snippet",
  "file_name": "test.txt",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "web_url": "http://example.com/snippets/1",
}
```

## Update snippet

Updates an existing snippet. The user must have permission to change an existing snippet.

```
PUT /snippets/:id
```

Parameters:

| Attribute          | Type    | Required | Description                |
| ---------          | ----    | -------- | -----------                |
| `id`               | Integer | yes      | The ID of a snippet        |
| `title`            | String  | no       | The title of a snippet     |
| `file_name`        | String  | no       | The name of a snippet file |
| `content`          | String  | no       | The content of a snippet   |
| `visibility_level` | Integer | no       | The snippet's visibility   |


``` bash
curl --request PUT --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" --data '{"title": "foo", "content": "bar"}' https://doggohub.example.com/api/v3/snippets/1
```

Example response:

``` json
{
  "id": 1,
  "title": "test",
  "file_name": "add.rb",
  "author": {
    "id": 1,
    "username": "john_smith",
    "email": "john@example.com",
    "name": "John Smith",
    "state": "active",
    "created_at": "2012-05-23T08:00:58Z"
  },
  "expires_at": null,
  "updated_at": "2012-06-28T10:52:04Z",
  "created_at": "2012-06-28T10:52:04Z",
  "web_url": "http://example.com/snippets/1",
}
```

## Delete snippet

Deletes an existing snippet. 

```
DELETE /snippets/:id
```

Parameters:

| Attribute          | Type    | Required | Description                   |
| ---------          | ----    | -------- | -----------                   |
| `id`               | Integer | yes      | The ID of a snippet           |


```
curl --request DELETE --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://doggohub.example.com/api/v3/snippets/1"
```

upon successful delete a `204 No content` HTTP code shall be expected, with no data,
but if the snippet is non-existent, a `404 Not Found` will be returned.

## Explore all public snippets

```
GET /snippets/public
```

| Attribute  | Type    | Required | Description                           |
| ---------  | ----    | -------- | -----------                           |
| `per_page` | Integer | no       | number of snippets to return per page |
| `page`     | Integer | no       | the page to retrieve                  |

``` bash
curl --header "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://doggohub.example.com/api/v3/snippets/public?per_page=2&page=1
```

Example response:

``` json
[
    {
        "author": {
            "avatar_url": "http://www.gravatar.com/avatar/edaf55a9e363ea263e3b981d09e0f7f7?s=80&d=identicon",
            "id": 12,
            "name": "Libby Rolfson",
            "state": "active",
            "username": "elton_wehner",
            "web_url": "http://localhost:3000/elton_wehner"
        },
        "created_at": "2016-11-25T16:53:34.504Z",
        "file_name": "oconnerrice.rb",
        "id": 49,
        "raw_url": "http://localhost:3000/snippets/49/raw",
        "title": "Ratione cupiditate et laborum temporibus.",
        "updated_at": "2016-11-25T16:53:34.504Z",
        "web_url": "http://localhost:3000/snippets/49"
    },
    {
        "author": {
            "avatar_url": "http://www.gravatar.com/avatar/36583b28626de71061e6e5a77972c3bd?s=80&d=identicon",
            "id": 16,
            "name": "Llewellyn Flatley",
            "state": "active",
            "username": "adaline",
            "web_url": "http://localhost:3000/adaline"
        },
        "created_at": "2016-11-25T16:53:34.479Z",
        "file_name": "muellershields.rb",
        "id": 48,
        "raw_url": "http://localhost:3000/snippets/48/raw",
        "title": "Minus similique nesciunt vel fugiat qui ullam sunt.",
        "updated_at": "2016-11-25T16:53:34.479Z",
        "web_url": "http://localhost:3000/snippets/48"
    }
]
```

