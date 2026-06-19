## _Echo — inspection utility autoload
## lightweight print/logging helpers for in-development interrogation.
## not a debug system — just a place to reach for when you need to look at something.
## methods are added from real callsite friction, not speculation.
## grep '_Echo.' before committing to catch stray calls.

extends Node

# Comb.valtype() - basic diagnostic print function for evaluating value and type of target
func valtype(label: String, targ: Variant) -> void:
	print(label, ": ", targ, " [", type_string(typeof(targ)), "]")

func log(message: String) -> void:
	print("[_Echo] " + message)

func tlog(message: String) -> void:
	print("[_Echo] [%d ms] " % Time.get_ticks_msec() + message)
