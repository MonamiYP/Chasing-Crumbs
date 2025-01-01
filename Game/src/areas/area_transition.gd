@tool
extends Area2D

@export_file("*.tscn") var area : String
@export var target_transition_area : String = "AreaTransition"
@export_category("Collision Area Settings")
@export var side : SIDE = SIDE.LEFT :
	set(_v) :
		side = _v
		update_area()
@export_range(1, 12, 1, "or_greater") var size : int = 2 : 
	set(_v) :
		size = _v
		update_area()
@export var is_active : bool = true
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

func _ready() -> void:
	update_area()
	if Engine.is_editor_hint():
		return
		
	monitoring = false
	place_player()
	await AreaManager.area_loaded
	monitoring = true
	
	body_entered.connect(player_entered)

func player_entered(_player : Node2D) -> void:
	if is_active:
		AreaManager.load_new_area(area, target_transition_area, get_offset())

func place_player() -> void:
	if name != AreaManager.target_transition:
		return
	PlayerManager.set_player_position(global_position + AreaManager.position_offset)

func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos : Vector2 = PlayerManager.player.global_position
	
	if side == SIDE.LEFT || side == SIDE.RIGHT:
		offset.y = player_pos.y - global_position.y
		offset.x = 64
		if side == SIDE.LEFT:
			offset.x *= -1
	if side == SIDE.TOP || side == SIDE.BOTTOM:
		offset.x = player_pos.x - global_position.x
		offset.y = 64
		if side == SIDE.TOP:
			offset.y *= -1
	
	return offset

func update_area() -> void:
	var new_rect : Vector2 = Vector2(32, 32)
	var new_position : Vector2 = Vector2.ZERO
	
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	else:
		new_rect.y *= size
		new_position.x += 16

	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position
