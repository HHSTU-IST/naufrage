extends Node
class_name DaySystem

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func start_day() -> void:
	GameState.set_dream_today(rng.randi_range(0, 1) == 1)
	GameState.day_changed.emit(GameState.current_day)

func end_day() -> void:
	GameState.advance_day()