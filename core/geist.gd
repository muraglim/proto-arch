class_name Geist
extends Node

@export var verbose := false

func geist_init() -> void:
	pass

func geist_shutdown() -> void:
	pass

func _log(msg: String) -> void:
	if verbose:
		print("[%s] " % name, msg)
