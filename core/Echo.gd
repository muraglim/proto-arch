## Echo — pure diagnostic logger.
## Lightweight print/debug output with no load-bearing logic.
## Returns void. Safe to disable or strip without affecting runtime.

extends Node

func valtype(label: String, targ: Variant) -> void:
	print("Echo.valtype", label, ": ", targ, " [", type_string(typeof(targ)), "]")

func log(message: String) -> void:
	print("Echo.log" + message)

func tlog(message: String) -> void:
	print("[%d ms] Echo.tlog " % Time.get_ticks_msec() + message)
