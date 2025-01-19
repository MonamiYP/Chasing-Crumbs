@tool
class_name DialogueInteraction extends Area2D

signal player_interacted
signal finished

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var enabled : bool = true
var dialogue_items : Array[ DialogueItem ]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	AreaManager.area_loaded.connect(load_current_dialogue)
	PuzzleManager.puzzle_complete.connect(_puzzle_finish)
	PuzzleManager.puzzle_giveup.connect(_puzzle_finish)

func load_current_dialogue() -> void:
	for item in get_children():
		if item is DialogueItem:
			remove_child(item)
			item.queue_free()
	dialogue_items.clear()
	
	var npc : NPC = get_parent()
	var dialog : String = DialogSystem.get_dialogue(npc.npc_resource.npc_name, GameManager.current_scene, npc.current_key)
	if dialog == "":
		enabled = false
	var dialog_split : Array = dialog.split('|')
	for d:String in dialog_split:
		var _dialog_item : DialogueItem = DialogueItem.new()
		_dialog_item.text = d
		_dialog_item.npc_info = npc.npc_resource
		add_child(_dialog_item)
	
	for item in get_children():
		if item is DialogueItem:
			dialogue_items.append(item)

func player_interact() -> void:
	await get_tree().process_frame
	if DialogSystem.is_active == false && enabled:
		player_interacted.emit()
		load_current_dialogue()
		DialogSystem.show_dialogue_ui(dialogue_items)
		DialogSystem.finished.connect(_on_dialogue_finished)

func _on_area_entered(_area : Area2D) -> void:
	if enabled:
		animation_player.play("show")
		PlayerManager.interact_pressed.connect(player_interact)

func _on_area_exited(_area : Area2D) -> void:
	if enabled:
		animation_player.play("hide")
		PlayerManager.interact_pressed.disconnect(player_interact)
	
func _on_dialogue_finished() -> void:
	DialogSystem.finished.disconnect(_on_dialogue_finished)

	var npc : NPC = get_parent()
	npc.update_key()
	if npc.current_key.rstrip("0123456789") == "Puzzle":
		PuzzleManager.load_puzzle(int(npc.current_key.replace("Puzzle", "")))
		PuzzleManager.current_puzzle_npc = npc
		
	finished.emit()

func _puzzle_finish() -> void:
	await get_tree().create_timer(0.5).timeout
	player_interact()
