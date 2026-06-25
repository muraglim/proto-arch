class_name Channel
extends Control

# Do not use _ready() in Channel subclasses.
# Use channel_init() instead - it fires after the channel
# is fully added to the scene tree and bootstrapper wiring is complete.

@export var verbose := false

func channel_init() -> void:
	pass

func channel_shutdown() -> void:
	pass

@warning_ignore("unused_parameter")
func show_overlay(text: String) -> void:
	pass

func hide_overlay() -> void:
	pass

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)
