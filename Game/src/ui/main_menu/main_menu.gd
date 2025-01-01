extends Control

@onready var start_button : Button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button
@onready var exit_button : Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button
@onready var starting_scene : String = "res://src/areas/areas/train_station.tscn"

func _ready() -> void:
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
func on_start_pressed() -> void:
	AreaManager.load_new_area(starting_scene, "StartArea", Vector2.ZERO)

func on_exit_pressed() -> void:
	get_tree().quit()
