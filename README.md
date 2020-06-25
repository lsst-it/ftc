# ftc

FTC provides automatic monitoring for foreman hosts, similar to how Nagios exported resources work but with 25% less pain.

## Requirements

* Foreman >= 1.23
* A telegraf instance running in Kubernetes, deployed by the [influxdata/telegraf Helm chart][telegraf-helm-chart]

[telegraf-helm-chart]: https://https://github.com/influxdata/helm-charts/tree/master/charts/telegraf

## Quickstart

```
./ftc --help
```

```
./ftc \
  --foreman-username=admin \
  --foreman-password=hunter2 \
  --foreman-url=https://foreman.dev.lsst.io:443 \
  --k8s-credentials=config \
  --k8s-namespace=telegraf-hosts \
  --k8s-configmap=telegraf-hosts \
  --k8s-configmap-key=ping.conf \
  --k8s-deployment=telegraf-hosts \
  --k8s-volume=config
```

## Implementation

Ftc is in charge of scraping and modifying host information from Foreman and shoving it into Kubernetes so telegraf can monitor hosts. It provides this functionality with the following algorithm.

1. Enumerate the Foreman API for all hosts and host interfaces
2. Generate a telegraf config file suitable to be written into `/etc/telegraf/telegraf.d/<input>.conf`
3. Compare the generated config file against a Kubernetes configmap holding the Telegraf config file. If they don't match the config file is updated within the configmap.
4. Check and potentially modify the Telegraf deployment so that it mounts the generated config file within `/etc/telegraf/telegraf.d/<input>.conf`; by default it'll be mounted in the wrong location (`/etc/telegraf/<input>.conf`).
5. Restart the deployment if the configmap or Deployment has changed to ensure that the new files are loaded. This works around [Kubernetes issue #50345][#50345]

[#50345]: https://github.com/kubernetes/kubernetes/issues/50345

FTC will automatically monitor Foreman host interfaces with the following properties:

1. The interface is managed by Foreman
2. The interface has an IP address/MAC address (on the assumption that interfaces without)
3. The interface has been assigned an FQDN

## Development

### Docker

```
FTC_VERSION="x.y.z" # substitute with your version
bundle exec rake docker:build
docker push lsstit/ftc:"${FTC_VERSION}"
```
