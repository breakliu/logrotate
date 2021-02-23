# Logrotate

Simplified version of [honestbee/logrotate](https://github.com/honestbee/logrotate), not configurable using environment variables. Instead a `logrotate.conf` file needs to be mounted into this container.

Updated to latest alpine image to fix some vulnerabilities.

## Usage

- Use shared volumes to add `/etc/logrotate.conf` into the container
- Use shared volumes to share log files with a container that produces logfiles
- Set `CRON_SCHEDULE`

### Standalone

```sh
docker run -it --rm \
  --env CRON_SCHEDULE='* * * * *' \
  -v $(pwd)/example/logrotate.conf:/etc/logrotate.conf:ro \
  -v $(pwd)/example/logs:/logs \
  skymatic/logrotate
# now log to example/logs/example.log and see rotation on every 1MiB
```

### Kubernetes

Example running logrotate as a sidecar for traefik:

```yml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: logs
spec:
  # ...
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: configs
data:
  logrotate.conf: |
    /logs/traefik.log {
        rotate 5
        copytruncate
        size 100M
        missingok
        nocompress

        postrotate
            pkill -USR1 traefik
        endscript
    }
---
kind: Deployment
apiVersion: apps/v1
metadata:
  # ...
spec:
  # ...
  template:
    spec:
      # ...
      shareProcessNamespace: true # allows access to traefik's PID from sidecar
      containers:
      - name: traefik
        # ...
      - name: logrotate
        image: skymatic/logrotate:latest
        env:
          - name: CRON_SCHEDULE
            value: "0 * * * *"
          - name: TINI_SUBREAPER # tini won't be PID 1 due to shareProcessNamespace
            value: 
        volumeMounts:
        - mountPath: /etc/logrotate.conf
          name: configs-vol
          subPath: logrotate.conf
          readOnly: true
        - mountPath: /logs/
          name: logs-vol
      volumes:
      - name: logs-vol
        persistentVolumeClaim:
            claimName: logs
      - name: configs-vol
        configMap:
          name: configs
```

## Customization

|Option|Default|Description|
|------|-------|-----------|
|`CRON_SCHEDULE`|`0 * * * *`|Cron schedule for logrotate command|

## See Also

- [Manpage for logrotate](https://linux.die.net/man/8/logrotate)
- [Log handling in Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/logging/)
