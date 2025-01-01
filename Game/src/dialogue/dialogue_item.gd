class_name DialogueItem extends Node

@export var npc_info : NPCResource
@export_multiline var text : String = "Text"

func _ready() -> void:
	check_npc_data()

func check_npc_data() -> void:
	if npc_info == null:
		var checking : bool = true
		while checking:
			var p : NPC = self.get_parent()
			if p:
				if p is NPC and p.npc_resource:
					npc_info = p.npc_resource
					checking = false
			else:
				checking = false
