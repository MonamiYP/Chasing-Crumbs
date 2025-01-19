extends Control

@onready var start_button : Button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button
@onready var exit_button : Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button
@onready var cutscene : String = "res://src/cutscenes/Cutscene1.tscn"

func _ready() -> void:
	start_button.button_down.connect(on_start_pressed)
	exit_button.button_down.connect(on_exit_pressed)
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_file(cutscene)

func on_exit_pressed() -> void:
	get_tree().quit()
