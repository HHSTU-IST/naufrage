extends Control

@onready var day_label = $Root/TopBar/DayLabel
@onready var food_label = $Root/TopBar/FoodLabel
@onready var dream_label = $Root/TopBar/DreamLabel
@onready var route_label = $Root/TopBar/RouteLabel
@onready var npc_label = $Root/NpcRow/NpcLabel
@onready var log_label = $Root/StatusLog
@onready var talk_button = $Root/Actions/TalkButton
@onready var rescue_button = $Root/Actions/RescueButton
@onready var forward_button = $Root/Actions/ForwardButton
@onready var back_button = $Root/Actions/BackButton
@onready var sleep_button = $Root/Actions/SleepButton
@onready var save_button = $Root/Actions/SaveButton
@onready var load_button = $Root/Actions/LoadButton
@onready var next_npc_button = $Root/NpcRow/NextNpcButton

func _ready() -> void:
	GameState.state_changed.connect(_refresh)
	GameState.day_changed.connect(_on_day_changed)
	GameState.food_changed.connect(_on_food_changed)
	GameState.ending_changed.connect(_on_ending_changed)
	talk_button.pressed.connect(func(): EventBus.dialogue_requested.emit(GameState.selected_npc_id))
	rescue_button.pressed.connect(func(): EventBus.rescue_requested.emit(GameState.selected_npc_id))
	forward_button.pressed.connect(func(): EventBus.route_requested.emit("forward"))
	back_button.pressed.connect(func(): EventBus.route_requested.emit("back"))
	sleep_button.pressed.connect(func(): EventBus.sleep_requested.emit())
	save_button.pressed.connect(func(): EventBus.save_requested.emit(0))
	load_button.pressed.connect(func(): EventBus.load_requested.emit(0))
	next_npc_button.pressed.connect(_cycle_npc)
	_refresh()

func _refresh() -> void:
	day_label.text = "Day %d" % GameState.current_day
	food_label.text = "Food: %d" % GameState.food
	dream_label.text = "Dream" if GameState.is_dream_today else "Reality"
	route_label.text = "%s / %d" % [GameState.current_route, GameState.route_distance]
	npc_label.text = "NPC: %s" % (GameState.selected_npc_id if not GameState.selected_npc_id.is_empty() else "-")
	talk_button.disabled = GameState.selected_npc_id.is_empty()
	rescue_button.disabled = GameState.selected_npc_id.is_empty()

func _on_day_changed(day: int) -> void:
	log_label.text = "新的第 %d 天开始" % day
	_refresh()

func _on_food_changed(food: int) -> void:
	_refresh()

func _on_ending_changed(ending_id: String) -> void:
	log_label.text = "结局: %s" % ending_id

func _cycle_npc() -> void:
	var order := ["fisher_west", "fisher_north", "fisher_east"]
	var index := order.find(GameState.selected_npc_id)
	if index < 0:
		index = 0
	else:
		index = (index + 1) % order.size()
	GameState.set_selected_npc(order[index])
	_refresh()