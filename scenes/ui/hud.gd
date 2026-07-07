extends Control

@onready var day_label = $TopBar/DayLabel
@onready var food_label = $TopBar/FoodLabel
@onready var dream_label = $TopBar/DreamLabel
@onready var route_label = $TopBar/RouteLabel
@onready var log_label = $StatusLog

func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	GameState.day_changed.connect(_on_day_changed)
	GameState.food_changed.connect(_on_food_changed)
	GameState.ending_changed.connect(_on_ending_changed)
	_refresh()

func _refresh() -> void:
	day_label.text = "Day %d" % GameState.current_day
	food_label.text = "Food: %d" % GameState.food
	dream_label.text = "Dream" if GameState.is_dream_today else "Reality"
	route_label.text = "%s / %d" % [GameState.current_route, GameState.route_distance]

func _on_day_changed(day: int) -> void:
	log_label.text = "新的第 %d 天开始" % day
	_refresh()

func _on_food_changed(food: int) -> void:
	_refresh()

func _on_ending_changed(ending_id: String) -> void:
	log_label.text = "结局: %s" % ending_id