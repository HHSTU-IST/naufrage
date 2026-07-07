extends Node

func _ready() -> void:
	GameState.reset_game()
	get_tree().change_scene_to_file("res://scenes/game/game_root.tscn")