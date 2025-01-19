class_name NPCResource extends Resource

@export var npc_name : String = ""
@export var sprite : Texture
@export var portrait : Texture
@export_range(0.5, 1.8, 0.05) var voice_pitch : float = 1.0
@export var puzzles : Array[int] = []
