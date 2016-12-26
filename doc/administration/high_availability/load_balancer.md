# Load Balancer for DoggoHub HA

In an active/active DoggoHub configuration, you will need a load balancer to route
traffic to the application servers. The specifics on which load balancer to use
or the exact configuration is beyond the scope of DoggoHub documentation. We hope
that if you're managing HA systems like DoggoHub you have a load balancer of
choice already. Some examples including HAProxy (open-source), F5 Big-IP LTM,
and Citrix Net Scaler. This documentation will outline what ports and protocols
you need to use with DoggoHub.

## Basic ports

| LB Port | Backend Port | Protocol        |
| ------- | ------------ | --------------- |
| 80      | 80           | HTTP  [^1]      |
| 443     | 443          | HTTPS [^1] [^2] |
| 22      | 22           | TCP             |

## DoggoHub Pages Ports

If you're using DoggoHub Pages you will need some additional port configurations.
DoggoHub Pages requires a separate VIP. Configure DNS to point the
`pages_external_url` from `/etc/doggohub/doggohub.rb` at the new VIP. See the
[DoggoHub Pages documentation][doggohub-pages] for more information.

| LB Port | Backend Port | Protocol |
| ------- | ------------ | -------- |
| 80      | Varies [^3]  | HTTP     |
| 443     | Varies [^3]  | TCP [^4] |

## Alternate SSH Port

Some organizations have policies against opening SSH port 22. In this case,
it may be helpful to configure an alternate SSH hostname that allows users
to use SSH on port 443. An alternate SSH hostname will require a new VIP
compared to the other DoggoHub HTTP configuration above.

Configure DNS for an alternate SSH hostname such as altssh.doggohub.example.com.

| LB Port | Backend Port | Protocol |
| ------- | ------------ | -------- |
| 443     | 22           | TCP      |

---

Read more on high-availability configuration:

1. [Configure the database](database.md)
1. [Configure Redis](redis.md)
1. [Configure NFS](nfs.md)
1. [Configure the DoggoHub application servers](doggohub.md)

[^1]: [Web terminal](../../ci/environments.md#web-terminals) support requires
      your load balancer to correctly handle WebSocket connections. When using
      HTTP or HTTPS proxying, this means your load balancer must be configured
      to pass through the `Connection` and `Upgrade` hop-by-hop headers. See the
      [web terminal](../integration/terminal.md) integration guide for
      more details.
[^2]: When using HTTPS protocol for port 443, you will need to add an SSL
      certificate to the load balancers. If you wish to terminate SSL at the
      DoggoHub application server instead, use TCP protocol.
[^3]: The backend port for DoggoHub Pages depends on the
      `doggohub_pages['external_http']` and `doggohub_pages['external_https']`
      setting. See [DoggoHub Pages documentation][doggohub-pages] for more details.
[^4]: Port 443 for DoggoHub Pages should always use the TCP protocol. Users can
      configure custom domains with custom SSL, which would not be possible
      if SSL was terminated at the load balancer.

[doggohub-pages]: http://docs.doggohub.com/ee/pages/administration.html
