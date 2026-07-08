extends Control

var _gs: Variant
var _eb: Variant
var _cdb: Variant

const NPC_SPRITE_MAP := {
	"fisher_west": "res://assets/sprites/npc-1-action.png",
	"fisher_north": "res://assets/sprites/npc-2-action.png",
	"fisher_east": "res://assets/sprites/npc-3-action.png",
}

@onready var day_label: Label = $Root/TopBar/DayLabel
@onready var food_label: Label = $Root/TopBar/FoodLabel
@onready var dream_label: Label = $Root/TopBar/DreamLabel
@onready var route_label: Label = $Root/TopBar/RouteLabel
@onready var npc_label: Label = $Root/NpcRow/NpcLabel
@onready var log_label: Label = $Root/StatusLog
@onready var talk_button: Button = $Root/Actions/TalkButton
@onready var rescue_button: Button = $Root/Actions/RescueButton
@onready var forward_button: Button = $Root/Actions/ForwardButton
@onready var back_button: Button = $Root/Actions/BackButton
@onready var sleep_button: Button = $Root/Actions/SleepButton
@onready var save_button: Button = $Root/Actions/SaveButton
@onready var load_button: Button = $Root/Actions/LoadButton
@onready var clear_button: Button = $Root/Actions/ClearButton
@onready var next_npc_button: Button = $Root/NpcRow/NextNpcButton
@onready var npc_sprite: TextureRect = $SceneLayer/NpcSprite
@onready var scene_background: TextureRect = $SceneBackground

func _ready() -> void:
	_gs = get_node("/root/GameState")
	_eb = get_node("/root/EventBus")
	_cdb = get_node("/root/ConfigDB")
	if _gs == null or _eb == null:
		push_error("HUD: autoload nodes not available")
		return
	if day_label == null or food_label == null or dream_label == null or route_label == null or npc_label == null or log_label == null:
		push_error("HUD: label nodes not available")
		return
	if talk_button == null or rescue_button == null or forward_button == null or back_button == null or sleep_button == null:
		push_error("HUD: button nodes not available")
		return
	if save_button == null or load_button == null or clear_button == null or next_npc_button == null:
		push_error("HUD: action button nodes not available")
		return
	_gs.state_changed.connect(_refresh)
	_gs.day_changed.connect(_on_day_changed)
	_gs.food_changed.connect(_on_food_changed)
	_gs.ending_changed.connect(_on_ending_changed)
	talk_button.pressed.connect(func(): _eb.dialogue_requested.emit(_gs.selected_npc_id))
	rescue_button.pressed.connect(func(): _eb.rescue_requested.emit(_gs.selected_npc_id))
	forward_button.pressed.connect(func(): _eb.route_requested.emit("forward"))
	back_button.pressed.connect(func(): _eb.route_requested.emit("back"))
	sleep_button.pressed.connect(func(): _eb.sleep_requested.emit())
	save_button.pressed.connect(func(): _eb.save_requested.emit(0))
	load_button.pressed.connect(func(): _eb.load_requested.emit(0))
	clear_button.pressed.connect(func(): _eb.clear_requested.emit(0))
	next_npc_button.pressed.connect(_cycle_npc)
	_refresh()

func _refresh() -> void:
	day_label.text = "Day %d" % _gs.current_day
	food_label.text = "Food: %d" % _gs.food
	dream_label.text = "Dream" if _gs.is_dream_today else "Reality"
	route_label.text = "%s / %d" % [_gs.current_route, _gs.route_distance]
	npc_label.text = "NPC: %s" % (_gs.selected_npc_id if not _gs.selected_npc_id.is_empty() else "-")
	talk_button.disabled = _gs.selected_npc_id.is_empty()
	rescue_button.disabled = _gs.selected_npc_id.is_empty()
	_update_npc_sprite()
	_update_scene_background()

func _update_npc_sprite() -> void:
	if npc_sprite == null:
		return
	var npc_id: String = _gs.selected_npc_id
	if npc_id.is_empty():
		npc_sprite.visible = false
		return
	npc_sprite.visible = true
	var path: String = NPC_SPRITE_MAP.get(npc_id, "")
	if not path.is_empty() and ResourceLoader.exists(path):
		npc_sprite.texture = load(path)

func _update_scene_background() -> void:
	if scene_background == null:
		return
	if _gs.is_dream_today:
		var dream_path: String = "res://assets/sprites/scene-dream.png"
		if ResourceLoader.exists(dream_path):
			scene_background.texture = load(dream_path)
	else:
		var main_path: String = "res://assets/sprites/ui-main.png"
		if ResourceLoader.exists(main_path):
			scene_background.texture = load(main_path)

func _on_day_changed(day: int) -> void:
	log_label.text = "新的第 %d 天开始" % day
	_refresh()

func _on_food_changed(_food: int) -> void:
	_refresh()

func _on_ending_changed(ending_id: String) -> void:
	log_label.text = "结局: %s" % ending_id
	# Show ending image overlay
	if not ending_id.is_empty() and _cdb != null:
		var ending_data: Variant = _cdb.get_ending(ending_id)
		if ending_data != null and ending_data.has_method("get") and not ending_data.image_path.is_empty():
			_show_ending_image(ending_data.image_path)

func _show_ending_image(image_path: String) -> void:
	if scene_background == null or not ResourceLoader.exists(image_path):
		return
	scene_background.texture = load(image_path)

func _cycle_npc() -> void:
	var order: Array[String] = ["fisher_west", "fisher_north", "fisher_east"]
	var index: int = order.find(_gs.selected_npc_id)
	if index < 0:
		index = 0
	else:
		index = (index + 1) % order.size()
	_gs.set_selected_npc(order[index])
	_refresh()