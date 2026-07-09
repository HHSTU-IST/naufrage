extends Node
class_name DaySystem

@onready var dream_system: DreamSystem = $"../DreamSystem"

func start_day() -> void:
	if dream_system != null:
		GameState.set_dream_today(dream_system.roll_today())
	else:
		GameState.set_dream_today(false)

func end_day() -> void:
	GameState.advance_day()