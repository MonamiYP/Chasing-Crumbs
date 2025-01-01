extends Node

signal area_load_started
signal area_loaded

var target_transition : String
var position_offset : Vector2

func _ready() -> void:
	await get_tree().process_frame
	area_loaded.emit()

func load_new_area(area_path : String, _target_transition : String, _position_offset : Vector2) -> void:
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.fade_out()
	
	area_load_started.emit()
	await get_tree().process_frame
	get_tree().change_scene_to_file(area_path)
	
	await SceneTransition.fade_in()

	get_tree().paused = false
	await get_tree().process_frame
	
	area_loaded.emit()
