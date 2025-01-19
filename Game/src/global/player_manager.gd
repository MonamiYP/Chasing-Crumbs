extends Node

const PLAYER : PackedScene = preload("res://src/characters/player.tscn")

var player : Player
var player_spawned : bool = false

signal interact_pressed

func _ready() -> void:
	pass

func player_spawn() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

func set_player_position(pos : Vector2) -> void:
	player.global_position = pos

func set_as_parent(parent : Node) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	parent.add_child(player)

func unparent_player(parent : Node) -> void:
	parent.remove_child(player)
