@tool
class_name DialogueInteraction extends Area2D

signal player_interacted
signal finished

@export var enabled : bool = true
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var dialogue_items : Array[ DialogueItem ]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
		
	for item in get_children():
		if item is DialogueItem:
			dialogue_items.append(item)

func player_interact() -> void:
	await get_tree().process_frame
	if DialogSystem.is_active == false:
		player_interacted.emit()
		DialogSystem.show_dialogue_ui(dialogue_items)
		DialogSystem.finished.connect(_on_dialogue_finished)

func _on_area_entered(_area : Area2D) -> void:
	if enabled == false || dialogue_items.size() == 0:
		return
	animation_player.play("show")
	PlayerManager.interact_pressed.connect(player_interact)

func _on_area_exited(_area : Area2D) -> void:
	animation_player.play("hide")
	PlayerManager.interact_pressed.disconnect(player_interact)

func _get_configuration_warnings() -> PackedStringArray:
	var is_error : bool = true
	for item in get_children():
		if item is DialogueItem:
			is_error = false
	
	if is_error:
		return [ "Needs at least one DialogueItem" ]
	else:
		return [ ]
	
func _on_dialogue_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialogue_finished)
	finished.emit()
