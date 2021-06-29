<?php

use PhpAmqpLib\Connection\AMQPStreamConnection;

$THRESHOLD_WARNING = getenv('WM_THRESHOLD_WARNING');
$THRESHOLD_CRITICAL = getenv('WM_THRESHOLD_CRITICAL');

if (!$THRESHOLD_WARNING) {
	$THRESHOLD_WARNING = 10;
}

if (!$THRESHOLD_CRITICAL) {
	$THRESHOLD_CRITICAL = 20;
}

$autoloadFile = dirname(dirname(__FILE__)) . '/vendor/autoload.php';

if (!file_exists($autoloadFile) || !is_readable($autoloadFile)) {
	echo sprintf('CRITICAL: autoload.php file does not exists in path %s', $autoloadFile);
	exit(2);
}

require_once $autoloadFile;

$queues = explode(',', getenv('WM_RABBITMQ_QUEUE'));

$resultsOk = [];
$resultsWarning = [];
$resultsCritical = [];


try {
	$connection = new AMQPStreamConnection(
		getenv('WM_RABBITMQ_HOST'),
		getenv('WM_RABBITMQ_PORT'),
		getenv('WM_RABBITMQ_LOGIN'),
		getenv('WM_RABBITMQ_PASSWORD'),
		getenv('WM_RABBITMQ_VHOST')
	);

	foreach ($queues as $queue) {
		$channel = $connection->channel();
		// explode tresholds
		list($queueName, $levelWarning, $levelCritical) = explode(':', $queue);

		if (!$levelWarning) $levelWarning = $THRESHOLD_WARNING;
		if (!$levelCritical) $levelCritical = $THRESHOLD_CRITICAL;

		$output = $channel->queue_declare($queueName,
			getenv('WM_IS_PASSIVE') ?: false,
			getenv('WM_IS_DURABLE') ?: false,
			getenv('WM_IS_EXLUSIVE') ?: false,
			getenv('WM_IS_AUTO_DELETE') ?: false,
			getenv('WM_IS_NOWAIT') ?: false
		);

		$numberOfMessagesInQueue = (int)(isset($output[1]) ? $output[1] : 0);
		$channel->close();

		if ($numberOfMessagesInQueue > $levelCritical) {
			$resultsCritical[] = sprintf('[%s][%s] Too many records: %d', '!!!', $queueName, $numberOfMessagesInQueue);
			continue;
		}

		if ($numberOfMessagesInQueue <= $levelCritical && $numberOfMessagesInQueue > $levelWarning) {
			$resultsWarning[] = sprintf('[%s][%s] Too many records: %d', '!', $queueName, $numberOfMessagesInQueue);
			continue;
		}

		$resultsOk[] = sprintf('[%s][%s] ok: %d', '✓', $queueName, $numberOfMessagesInQueue);
	}
} catch (Exception $e) {
	echo sprintf('CRITICAL: There is some error in Rabbit connection: %s', $e->getMessage());
	exit(2);
}

$connection->close();

if ($resultsCritical) {
	echo implode(PHP_EOL, $resultsCritical);
	echo PHP_EOL;
}

if ($resultsWarning) {
	echo implode(PHP_EOL, $resultsWarning);
	echo PHP_EOL;
}

if ($resultsOk) {
	echo implode(PHP_EOL, $resultsOk);
	echo PHP_EOL;
}

// now exit with a proper code
if ($resultsCritical) {
	exit(2);
}

if ($resultsWarning) {
	exit(2);
}

if ($resultsOk) {
	exit(0);
}

echo 'Some uknown error appeared';
exit(2);
