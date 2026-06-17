extends Node

# Linker - dependency orchestration autoload.
# Replaces the channel-as-mediator pattern for Channel/Daemon wiring.
# Channels call Linker.register(self) in channel_init().
# Linker reads the dep ledger, boots daemons in order, executes wiring declarations.
# Main calls Linker.register_main() in _ready() before any channel boots.

var _main: Node = null
var _front: Node = null
var _back: Node = null
var _under: Node = null

# Per-session registry: maps role string -> live node reference.
# Keyed by channel name, cleared on channel shutdown.
# "channel" is a reserved role — always resolves to the registering Channel.
# Daemons do not register sub-daemons in this architecture.
var _registries: Dictionary = {}

func register_main(main: Node, front: Node, back: Node, under: Node) -> void:
	_main = main
	_front = front
	_back = back
	_under = under
	print("[Linker] register_main(): main wired.")

func register(channel: Channel) -> void:
	var key = channel.name.to_lower()
	var deps = Firm.get_value("_dep_ledger", key)
	if deps == null:
		print("[Linker] register(%s): no dep entry found, nothing to do." % key)
		return
	_registries[key] = {"channel": channel}
	print("[Linker] register(%s): registry initialized." % key)