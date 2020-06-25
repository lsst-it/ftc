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

## Configuration

Configuration can be passed to ftc through environment variables or CLI options. If an option is specified via both an environment and CLI option the CLI option will take precedence.

### Configuration reference

| Option                | Env var             | Description                                                              | Example                           |
| ------                | -------             | -----------                                                              | -------                           |
| `--help`              | n/a                 | Print the help docs and exit                                             | n/a                               |
| `--debug`             | n/a                 | Enable debug level logging                                               | n/a                               |
| `--foreman-username`  | `FOREMAN_USERNAME`  | Foreman username                                                         | `admin`                           |
| `--foreman-password`  | `FOREMAN_PASSWORD`  | Foreman password                                                         | `hunter2`                         |
| `--foreman-url`       | `FOREMAN_URL`       | Foreman base URL                                                         | `https://foreman.ls.lsst.org:443` |
| `--ssl-ca-file`       | `SSL_CA_FILE`       | Foreman CA certificate path                                              | `/config/ca.crt`                  |
| `--k8s-credentials`   | `K8S_CREDENTIALS`   | The k8s credentials, either "cluster" or "config" (`~/.kube/config`)     | `cluster`                         |
| `--k8s-namespace`     | `K8S_NAMESPACE`     | The k8s namespace hosting the Telegraf monitoring instances              | `it-telegraf-hosts`               |
| `--k8s-configmap`     | `K8S_CONFIGMAP`     | The k8s configmap holding the Telegraf config files                      | `telegraf-ping`                   |
| `--k8s-configmap-key` | `K8S_CONFIGMAP_KEY` | The k8s configmap key where the generated Telegraf config will be stored | `ping.conf`                       |
| `--k8s-deployment`    | `K8S_DEPLOYMENT`    | The Telegraf deployment where volume mounts will be managed              | `telegraf-ping`                   |
| `--k8s-volume`        | `K8S_VOLUME`        | The volume name associated with the Telegraf configmap                   | `it-telegraf-hosts`               |
| `--formatter-name`    | `FORMATTER_NAME`    | The Telegraf config formatter, one of `ping` or `dns_forward`            | `ping`                            |
| `--formatter-options` | `FORMATTER_OPTIONS` | [Additional configuration](#formatters) for a Telegraf config formatter  | `{"exclude_fqdns": [".*-pxe\."]}` |

#### Formatters

Additional options can be supplied to formatters. Additional options are specified as a JSON string.

* `exclude_fqdns`: A list of regular expressions of FQDNs to ignore. This is generally used to ignore interfaces used for PXE booting and are shut down during normal operation.
* `servers` (`dns_forward` only): A list of DNS servers to perform DNS queries against.

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
