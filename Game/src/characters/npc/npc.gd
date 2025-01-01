class_name NPC extends CharacterBody2D

var speed : int = 150
var acceleration : int = 20
var current_state : STATES = STATES.IDLE
var direction : Vector2 = Vector2.RIGHT

var player : Player
var is_talking_to_player : bool = false
var is_player_in_range : bool = false

enum STATES {
	IDLE,
	MOVE,
	CHAT
}

@export var npc_resource : NPCResource
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	setup_npc()
	if Engine.is_editor_hint():
		return
	connect_dialogue()

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	move_and_slide()

func setup_npc() -> void:
	if npc_resource:
		if sprite:
			sprite.texture = npc_resource.sprite

func update_direction(target_position : Vector2) -> void:
	direction = global_position.direction_to(target_position)

func connect_dialogue() -> void:
	for item in get_children():
		if item is DialogueInteraction:
			item.player_interacted.connect(_on_player_interact)
			item.finished.connect(_on_player_leave)
			
func _on_player_interact() -> void:
	update_direction(PlayerManager.player.global_position)
	current_state = STATES.CHAT

func _on_player_leave() -> void:
	current_state = STATES.IDLE
