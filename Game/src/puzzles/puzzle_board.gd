class_name PuzzleBoard extends Control

var puzzle_scene : Node

func load_puzzle(puzzle_no : int) -> void:
	var puzzle_path : String = "res://src/puzzles/puzzle_" + str(puzzle_no) + "/board.tscn"
	puzzle_scene = load(puzzle_path).instantiate()
	add_child(puzzle_scene)

func puzzle_complete() -> void:
	puzzle_scene.queue_free()
