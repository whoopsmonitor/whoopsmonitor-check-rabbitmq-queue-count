# whoopsmonitor-check-rabbitmq-queue-count
Check amount of records in RabbitMQ queue.

## Environmental variables

 - `WM_RABBITMQ_QUEUE`
 - `WM_RABBITMQ_HOST`
 - `WM_RABBITMQ_PORT`
 - `WM_RABBITMQ_LOGIN`
 - `WM_RABBITMQ_PASSWORD`
 - `WM_RABBITMQ_VHOST`
 - `WM_IS_PASSIVE`
 - `WM_IS_DURABLE`
 - `WM_IS_EXLUSIVE`
 - `WM_IS_AUTO_DELETE`
 - `WM_IS_NOWAIT`
 - `WM_THRESHOLD_WARNING`, default is 10
 - `WM_THRESHOLD_CRITICAL`, default is 20

### `RABBITMQ_QUEUE`
You can use multiple queues. Just separate then with coma like:

```yaml
WM_RABBITMQ_QUEUE=my-queue,my-other-queue
```

### Thresholds
You can override either warning or critical thresholds. You can set the threshold right after the check name, separated with colon. First one is for warning and the second one for critical level.

Example:

```yaml
WM_RABBITMQ_QUEUE=my-queue:50:100
```

## Example

Details of the check in Whoops Monitor configuration tab or for the `.env` file.

```yaml
WM_RABBITMQ_QUEUE=my-queue
WM_RABBITMQ_HOST=localhost
WM_RABBITMQ_PORT=5672
WM_RABBITMQ_LOGIN=user
WM_RABBITMQ_PASSWORD=password
WM_RABBITMQ_VHOST=/
WM_IS_PASSIVE=false
WM_IS_DURABLE=false
WM_IS_EXLUSIVE=false
WM_IS_AUTO_DELETE=false
WM_IS_NOWAIT=false
WM_THRESHOLD_WARNING=30
WM_THRESHOLD_CRITICAL=80
```

## Output

 - `0` - Amount of records is ok.
 - `1` - Amount of records is at warning level.
 - `2` - Amount of records is at critical level.


## Build
```bash
docker build -t whoopsmonitor-check-rabbitmq-queue-count .
```

## Run

```bash
docker run --rm --env-file .env whoopsmonitor-check-rabbitmq-queue-count
```
