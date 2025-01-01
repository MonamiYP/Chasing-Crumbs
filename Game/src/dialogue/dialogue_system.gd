class_name DialogueSystem extends CanvasLayer

@export_file("*.json") var dialogue_file : String

@onready var dialog_ui : Control = $DialogueUI
@onready var content : Label = $DialogueUI/NinePatchRect/Text
@onready var name_label : Label = $DialogueUI/NinePatchRect/Name
@onready var next_indicator : Panel = $DialogueUI/NextDialogue
@onready var next_indicator_text : Label = $DialogueUI/NextDialogue/Label
@onready var timer: Timer = $DialogueUI/Timer
@onready var audio_stream_player: AudioStreamPlayer = $DialogueUI/AudioStreamPlayer


var dialogue : Array
var is_active : bool = false

var dialogue_items : Array[DialogueItem]
var dialogue_item_index : int = 0

var plain_text : String
var text_speed : float = 0.01
var text_length : int = 0
var text_in_progress : bool = false
var pitch_base : float = 1.0

signal finished

func _ready() -> void:
	dialogue = load_dialogue(dialogue_file)
	timer.timeout.connect(on_timer_timeout)
	#$NinePatchRect/Name.text = dialogue[0]['name']
	#$NinePatchRect/Text.text = dialogue[1]['text']
	hide_dialogue() 
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if is_active == false:
			return
		if text_in_progress == true:
			text_in_progress = false
			content.visible_characters = text_length
			timer.stop()
			show_dialogue_next_indicator(true)
			return 
		dialogue_item_index += 1
		if dialogue_item_index < dialogue_items.size():
			next_dialogue()
		else:
			hide_dialogue()

func load_dialogue(file_path: String) -> Array:
	var file : FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var data : Array = JSON.parse_string(file.get_as_text())
	return data

func show_dialogue_ui(items : Array[DialogueItem]) -> void:
	is_active = true
	dialog_ui.visible = true
	dialog_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	
	dialogue_items = items
	dialogue_item_index = 0

	next_dialogue()

func hide_dialogue() -> void:
	dialog_ui.visible = false
	dialog_ui.process_mode = Node.PROCESS_MODE_DISABLED
	finished.emit()
	await get_tree().process_frame
	is_active = false

func next_dialogue() -> void:
	show_dialogue_next_indicator(false)
	content.text = dialogue_items[dialogue_item_index].text
	name_label.text = dialogue_items[dialogue_item_index].npc_info.npc_name
	pitch_base = dialogue_items[dialogue_item_index].npc_info.voice_pitch
	
	content.visible_characters = 0
	text_length = content.get_total_character_count()
	plain_text = content.text
	text_in_progress = true
	start_text_timer()

func show_dialogue_next_indicator(_visible : bool) -> void:
	next_indicator.visible = _visible
	if dialogue_item_index + 1 < dialogue_items.size():
		next_indicator_text.text = "NEXT"
	else:
		next_indicator_text.text = "END"

func start_text_timer() -> void:
	timer.wait_time = text_speed
	var c : String = plain_text[content.visible_characters - 1]
	if '.,!?:;'.contains(c):
		timer.wait_time *= 6
	timer.start()

func on_timer_timeout() -> void:
	content.visible_characters += 1
	
	if content.visible_characters <= text_length:
		audio_stream_player.pitch_scale = randf_range(pitch_base - 0.04, pitch_base + 0.04)
		audio_stream_player.play()
		start_text_timer()
	else:
		show_dialogue_next_indicator(true)
		text_in_progress = false
		
