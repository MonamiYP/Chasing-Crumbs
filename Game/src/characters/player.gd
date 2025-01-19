class_name Player extends CharacterBody2D

var speed : int = 150
var acceleration : int = 50

@onready var camera : Camera2D = $Camera2D

func _ready() -> void:
	PlayerManager.player = self

func _process(delta: float) -> void:
	var input : Vector2 = Input.get_vector("left", "right", "up", "down") * speed * delta
	velocity = lerp(velocity, input * speed, delta * acceleration)
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	elif velocity.x < 0:
		$Sprite2D.flip_h = true
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
		

func _physics_process(_delta: float) -> void:
	move_and_slide()
