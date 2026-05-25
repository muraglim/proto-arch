class_name Module
extends Node

enum TransitionType {
	DESTROY,   # 
	BACKGROUND # Send the old module to the BackgroundContainer
}

signal nav_req(target_module_path: String, transition: TransitionType)

func req_exit(next_dest: String, transition_type: TransitionType = TransitionType.DESTROY) -> void:
	nav_req.emit(next_dest, transition_type)

func module_init() -> void:
	pass
	
func module_pause() -> void:
	pass
	
func module_resume() -> void:
	pass

func module_teardown() -> void:
	pass
