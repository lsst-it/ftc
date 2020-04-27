# ftc

Foreman/Telegraf config

## Usage

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
## Description

Generate and populate Telegraf configs based on foreman hosts.

## Development

### Docker

```
FTC_VERSION="x.y.z" # substitute with your version
bundle exec rake docker:build
docker push lsstit/ftc:"${FTC_VERSION}"
```
