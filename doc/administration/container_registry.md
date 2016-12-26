# DoggoHub Container Registry administration

> [Introduced][ce-4040] in DoggoHub 8.8.

---

> **Notes:**
- Container Registry manifest `v1` support was added in DoggoHub 8.9 to support
  Docker versions earlier than 1.10.
- This document is about the admin guide. To learn how to use DoggoHub Container
  Registry [user documentation](../user/project/container_registry.md).

With the Container Registry integrated into DoggoHub, every project can have its
own space to store its Docker images.

You can read more about the Container Registry at
https://docs.docker.com/registry/introduction/.

## Enable the Container Registry

**Omnibus DoggoHub installations**

All you have to do is configure the domain name under which the Container
Registry will listen to. Read
[#container-registry-domain-configuration](#container-registry-domain-configuration)
and pick one of the two options that fits your case.

>**Note:**
The container registry works under HTTPS by default. Using HTTP is possible
but not recommended and out of the scope of this document.
Read the [insecure Registry documentation][docker-insecure] if you want to
implement this.

---

**Installations from source**

If you have installed DoggoHub from source:

1. You will have to [install Registry][registry-deploy] by yourself.
1. After the installation is complete, you will have to configure the Registry's
   settings in `doggohub.yml` in order to enable it.
1. Use the sample NGINX configuration file that is found under
   [`lib/support/nginx/registry-ssl`][registry-ssl] and edit it to match the
   `host`, `port` and TLS certs paths.

The contents of `doggohub.yml` are:

```
registry:
  enabled: true
  host: registry.doggohub.example.com
  port: 5005
  api_url: http://localhost:5000/
  key: config/registry.key
  path: shared/registry
  issuer: doggohub-issuer
```

where:

| Parameter | Description |
| --------- | ----------- |
| `enabled` | `true` or `false`. Enables the Registry in DoggoHub. By default this is `false`. |
| `host`    | The host URL under which the Registry will run and the users will be able to use. |
| `port`    | The port under which the external Registry domain will listen on. |
| `api_url` | The internal API URL under which the Registry is exposed to. It defaults to `http://localhost:5000`. |
| `key`     | The private key location that is a pair of Registry's `rootcertbundle`. Read the [token auth configuration documentation][token-config]. |
| `path`    | This should be the same directory like specified in Registry's `rootdirectory`. Read the [storage configuration documentation][storage-config]. This path needs to be readable by the DoggoHub user, the web-server user and the Registry user. Read more in [#container-registry-storage-path](#container-registry-storage-path). |
| `issuer`  | This should be the same value as configured in Registry's `issuer`. Read the [token auth configuration documentation][token-config]. |

>**Note:**
A Registry init file is not shipped with DoggoHub if you install it from source.
Hence, [restarting DoggoHub][restart doggohub] will not restart the Registry should
you modify its settings. Read the upstream documentation on how to achieve that.

At the absolute minimum, make sure your [Registry configuration][registry-auth]
has `container_registry` as the service and `https://doggohub.example.com/jwt/auth`
as the realm:

```
auth:
  token:
    realm: https://doggohub.example.com/jwt/auth
    service: container_registry
    issuer: doggohub-issuer
    rootcertbundle: /root/certs/certbundle
```

## Container Registry domain configuration

There are two ways you can configure the Registry's external domain.

- Either [use the existing DoggoHub domain][existing-domain] where in that case
  the Registry will have to listen on a port and reuse DoggoHub's TLS certificate,
- or [use a completely separate domain][new-domain] with a new TLS certificate
  for that domain.

Since the container Registry requires a TLS certificate, in the end it all boils
down to how easy or pricey is to get a new one.

Please take this into consideration before configuring the Container Registry
for the first time.

### Configure Container Registry under an existing DoggoHub domain

If the Registry is configured to use the existing DoggoHub domain, you can
expose the Registry on a port so that you can reuse the existing DoggoHub TLS
certificate.

Assuming that the DoggoHub domain is `https://doggohub.example.com` and the port the
Registry is exposed to the outside world is `4567`, here is what you need to set
in `doggohub.rb` or `doggohub.yml` if you are using Omnibus DoggoHub or installed
DoggoHub from source respectively.

>**Note:**
Be careful to choose a port different than the one that Registry listens to (`5000` by default),
otherwise you will run into conflicts .

---

**Omnibus DoggoHub installations**

1. Your `/etc/doggohub/doggohub.rb` should contain the Registry URL as well as the
   path to the existing TLS certificate and key used by DoggoHub:

    ```ruby
    registry_external_url 'https://doggohub.example.com:4567'
    ```

    Note how the `registry_external_url` is listening on HTTPS under the
    existing DoggoHub URL, but on a different port.

    If your TLS certificate is not in `/etc/doggohub/ssl/doggohub.example.com.crt`
    and key not in `/etc/doggohub/ssl/doggohub.example.com.key` uncomment the lines
    below:

    ```ruby
    registry_nginx['ssl_certificate'] = "/path/to/certificate.pem"
    registry_nginx['ssl_certificate_key'] = "/path/to/certificate.key"
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

1. Open `/home/git/doggohub/config/doggohub.yml`, find the `registry` entry and
   configure it with the following settings:

    ```
    registry:
      enabled: true
      host: doggohub.example.com
      port: 4567
    ```

1. Save the file and [restart DoggoHub][] for the changes to take effect.
1. Make the relevant changes in NGINX as well (domain, port, TLS certificates path).

---

Users should now be able to login to the Container Registry with their DoggoHub
credentials using:

```bash
docker login doggohub.example.com:4567
```

### Configure Container Registry under its own domain

If the Registry is configured to use its own domain, you will need a TLS
certificate for that specific domain (e.g., `registry.example.com`) or maybe
a wildcard certificate if hosted under a subdomain  of your existing DoggoHub
domain (e.g., `registry.doggohub.example.com`).

Let's assume that you want the container Registry to be accessible at
`https://registry.doggohub.example.com`.

---

**Omnibus DoggoHub installations**

1. Place your TLS certificate and key in
   `/etc/doggohub/ssl/registry.doggohub.example.com.crt` and
   `/etc/doggohub/ssl/registry.doggohub.example.com.key` and make sure they have
   correct permissions:

    ```bash
    chmod 600 /etc/doggohub/ssl/registry.doggohub.example.com.*
    ```

1. Once the TLS certificate is in place, edit `/etc/doggohub/doggohub.rb` with:

    ```ruby
    registry_external_url 'https://registry.doggohub.example.com'
    ```

    Note how the `registry_external_url` is listening on HTTPS.

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

> **Note:**
If you have a [wildcard certificate][], you need to specify the path to the
certificate in addition to the URL, in this case `/etc/doggohub/doggohub.rb` will
look like:
>
```ruby
registry_nginx['ssl_certificate'] = "/etc/doggohub/ssl/certificate.pem"
registry_nginx['ssl_certificate_key'] = "/etc/doggohub/ssl/certificate.key"
```

---

**Installations from source**

1. Open `/home/git/doggohub/config/doggohub.yml`, find the `registry` entry and
   configure it with the following settings:

    ```
    registry:
      enabled: true
      host: registry.doggohub.example.com
    ```

1. Save the file and [restart DoggoHub][] for the changes to take effect.
1. Make the relevant changes in NGINX as well (domain, port, TLS certificates path).

---

Users should now be able to login to the Container Registry using their DoggoHub
credentials:

```bash
docker login registry.doggohub.example.com
```

## Disable Container Registry site-wide

>**Note:**
Disabling the Registry in the Rails DoggoHub application as set by the following
steps, will not remove any existing Docker images. This is handled by the
Registry application itself.

**Omnibus DoggoHub**

1. Open `/etc/doggohub/doggohub.rb` and set `registry['enable']` to `false`:

    ```ruby
    registry['enable'] = false
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

1. Open `/home/git/doggohub/config/doggohub.yml`, find the `registry` entry and
   set `enabled` to `false`:

    ```
    registry:
      enabled: false
    ```

1. Save the file and [restart DoggoHub][] for the changes to take effect.

## Disable Container Registry for new projects site-wide

If the Container Registry is enabled, then it will be available on all new
projects. To disable this function and let the owners of a project to enable
the Container Registry by themselves, follow the steps below.

---

**Omnibus DoggoHub installations**

1. Edit `/etc/doggohub/doggohub.rb` and add the following line:

    ```ruby
    doggohub_rails['doggohub_default_projects_features_container_registry'] = false
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

1. Open `/home/git/doggohub/config/doggohub.yml`, find the `default_projects_features`
   entry and configure it so that `container_registry` is set to `false`:

    ```
    ## Default project features settings
    default_projects_features:
      issues: true
      merge_requests: true
      wiki: true
      snippets: false
      builds: true
      container_registry: false
    ```

1. Save the file and [restart DoggoHub][] for the changes to take effect.

## Container Registry storage path

>**Note:**
For configuring storage in the cloud instead of the filesystem, see the
[storage driver configuration](#container-registry-storage-driver).

If you want to store your images on the filesystem, you can change the storage
path for the Container Registry, follow the steps below.

This path is accessible to:

- the user running the Container Registry daemon,
- the user running DoggoHub

> **Warning** You should confirm that all DoggoHub, Registry and web server users
have access to this directory.

---

**Omnibus DoggoHub installations**

The default location where images are stored in Omnibus, is
`/var/opt/doggohub/doggohub-rails/shared/registry`. To change it:

1. Edit `/etc/doggohub/doggohub.rb`:

    ```ruby
    doggohub_rails['registry_path'] = "/path/to/registry/storage"
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

The default location where images are stored in source installations, is
`/home/git/doggohub/shared/registry`. To change it:

1. Open `/home/git/doggohub/config/doggohub.yml`, find the `registry` entry and
   change the `path` setting:

    ```
    registry:
      path: shared/registry
    ```

1. Save the file and [restart DoggoHub][] for the changes to take effect.

## Container Registry storage driver

You can configure the Container Registry to use a different storage backend by
configuring a different storage driver. By default the DoggoHub Container Registry
is configured to use the filesystem driver, which makes use of [storage path](#container-registry-storage-path)
configuration.

The different supported drivers are:

| Driver     | Description                         |
|------------|-------------------------------------|
| filesystem | Uses a path on the local filesystem |
| azure      | Microsoft Azure Blob Storage        |
| gcs        | Google Cloud Storage                |
| s3         | Amazon Simple Storage Service       |
| swift      | OpenStack Swift Object Storage      |
| oss        | Aliyun OSS                          |

Read more about the individual driver's config options in the
[Docker Registry docs][storage-config].

> **Warning** DoggoHub will not backup Docker images that are not stored on the
filesystem. Remember to enable backups with your object storage provider if
desired.

---

**Omnibus DoggoHub installations**

To configure the storage driver in Omnibus:

1. Edit `/etc/doggohub/doggohub.rb`:

    ```ruby
    registry['storage'] = {
      's3' => {
        'accesskey' => 's3-access-key',
        'secretkey' => 's3-secret-key-for-access-key',
        'bucket' => 'your-s3-bucket',
        'region' => 'your-s3-region'
      }
    }
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

Configuring the storage driver is done in your registry config YML file created
when you [deployed your docker registry][registry-deploy].

Example:

```
storage:
  s3:
    accesskey: 'AKIAKIAKI'
    secretkey: 'secret123'
    bucket: 'doggohub-registry-bucket-AKIAKIAKI'
    region: 'your-s3-region'
  cache:
    blobdescriptor: inmemory
  delete:
    enabled: true
```

## Change the registry's internal port

> **Note:**
This is not to be confused with the port that DoggoHub itself uses to expose
the Registry to the world.

The Registry server listens on localhost at port `5000` by default,
which is the address for which the Registry server should accept connections.
In the examples below we set the Registry's port to `5001`.

**Omnibus DoggoHub**

1. Open `/etc/doggohub/doggohub.rb` and set `registry['registry_http_addr']`:

    ```ruby
    registry['registry_http_addr'] = "localhost:5001"
    ```

1. Save the file and [reconfigure DoggoHub][] for the changes to take effect.

---

**Installations from source**

1. Open the configuration file of your Registry server and edit the
   [`http:addr`][registry-http-config] value:

    ```
    http
      addr: localhost:5001
    ```

1. Save the file and restart the Registry server.

## Disable Container Registry per project

If Registry is enabled in your DoggoHub instance, but you don't need it for your
project, you can disable it from your project's settings. Read the user guide
on how to achieve that.

## Storage limitations

Currently, there is no storage limitation, which means a user can upload an
infinite amount of Docker images with arbitrary sizes. This setting will be
configurable in future releases.

## Changelog

**DoggoHub 8.8 ([source docs][8-8-docs])**

- DoggoHub Container Registry feature was introduced.

[reconfigure doggohub]: restart_doggohub.md#omnibus-doggohub-reconfigure
[restart doggohub]: restart_doggohub.md#installations-from-source
[wildcard certificate]: https://en.wikipedia.org/wiki/Wildcard_certificate
[ce-4040]: https://doggohub.com/doggohub-org/doggohub-ce/merge_requests/4040
[docker-insecure]: https://docs.docker.com/registry/insecure/
[registry-deploy]: https://docs.docker.com/registry/deploying/
[storage-config]: https://docs.docker.com/registry/configuration/#storage
[registry-http-config]: https://docs.docker.com/registry/configuration/#http
[registry-auth]: https://docs.docker.com/registry/configuration/#auth
[token-config]: https://docs.docker.com/registry/configuration/#token
[8-8-docs]: https://doggohub.com/doggohub-org/doggohub-ce/blob/8-8-stable/doc/administration/container_registry.md
[registry-ssl]: https://doggohub.com/doggohub-org/doggohub-ce/blob/master/lib/support/nginx/registry-ssl
[existing-domain]: #configure-container-registry-under-an-existing-doggohub-domain
[new-domain]: #configure-container-registry-under-its-own-domain
