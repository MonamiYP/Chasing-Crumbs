extends Node

var current_scene : String = '1'
var events_file : Dictionary
var events_json : String = "res://res/events.json"

var current_puzzle_npc : NPC

signal start_puzzle
signal puzzle_complete
signal puzzle_giveup

func _ready() -> void:
	events_file = load_events(events_json)

func load_events(file_path: String) -> Dictionary:
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var data : Dictionary = JSON.parse_string(file.get_as_text())
	return data

func update_scene() -> void:
	# MODIFY
	current_scene = '2'

func get_event(npc_name : String, scene : String) -> Dictionary:
	var _event : Dictionary
	_event = events_file[scene]['Character'][npc_name] 
	return _event
