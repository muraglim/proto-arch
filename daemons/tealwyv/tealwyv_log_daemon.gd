class_name TealwyvLogDaemon
extends Daemon

func wire_to_channel(channel: Channel) -> void:
	var forest = channel as TealwyvForestChannel
	if forest == null: return
	forest.register_log_daemon(self)

func daemon_shutdown() -> void:
	_log("daemon_shutdown(): log daemon offline.")