extends Node2D

@onready var animPlayer : AnimationPlayer = $AnimationPlayer
@export_file("*.tscn") var nextScene : String
var player : Player

func _ready() -> void:
	play_cutscene()

func play_cutscene() -> void:
	animPlayer.play("cutscene")
	if get_tree().get_nodes_in_group("Player"):
		player.camera.enabled = false

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	AreaManager.load_new_area(nextScene, "Cutscene", Vector2.ZERO)
