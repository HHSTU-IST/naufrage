extends Control

var _gs: Variant
var _eb: Variant
var _cdb: Variant

# 每个 NPC 的状态 → 精灵路径映射
const NPC_STATE_SPRITES := {
	"fisher_west": {
		0: "res://assets/sprites/渔夫/A_west_01_coma_injured.png",
		1: "res://assets/sprites/渔夫/A_west_02_awake.png",
		2: "res://assets/sprites/渔夫/A_west_03_recover.png",
		3: "res://assets/sprites/渔夫/A_west_04_stand_full.png",
	},
	"fisher_north": {
		0: "res://assets/sprites/渔夫/B_north_01_coma_injured.png",
		1: "res://assets/sprites/渔夫/B_north_02_awake.png",
		2: "res://assets/sprites/渔夫/B_north_03_recover.png",
		3: "res://assets/sprites/渔夫/B_north_04_stand_full.png",
	},
	"fisher_east": {
		0: "res://assets/sprites/渔夫/C_east_01_injured_initial.png",
		1: "res://assets/sprites/渔夫/C_east_02_awake.png",
		2: "res://assets/sprites/渔夫/C_east_03_recover.png",
		3: "res://assets/sprites/渔夫/C_east_04_stand_full.png",
	},
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
@onready var west_button: Button = $Root/NpcRow/WestNpcButton
@onready var north_button: Button = $Root/NpcRow/NorthNpcButton
@onready var east_button: Button = $Root/NpcRow/EastNpcButton
@onready var npc_west_sprite: TextureRect = $NpcWestSprite
@onready var npc_north_sprite: TextureRect = $NpcNorthSprite
@onready var npc_east_sprite: TextureRect = $NpcEastSprite
@onready var scene_background: TextureRect = $SceneBackground
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_speaker: Label = $DialoguePanel/DialogueBox/DialogueSpeaker
@onready var dialogue_text: Label = $DialoguePanel/DialogueBox/DialogueText

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
	if save_button == null or load_button == null or clear_button == null:
		push_error("HUD: action button nodes not available")
		return
	if west_button == null or north_button == null or east_button == null:
		push_error("HUD: NPC buttons not available")
		return
	_gs.state_changed.connect(_refresh)
	_gs.day_changed.connect(_on_day_changed)
	_gs.food_changed.connect(_on_food_changed)
	_gs.ending_changed.connect(_on_ending_changed)
	_gs.npc_state_changed.connect(_on_npc_state_changed)
	_eb.dialogue_displayed.connect(_on_dialogue_displayed)
	talk_button.pressed.connect(func(): _eb.dialogue_requested.emit(_gs.selected_npc_id))
	rescue_button.pressed.connect(func(): _eb.rescue_requested.emit(_gs.selected_npc_id))
	forward_button.pressed.connect(func(): _eb.route_requested.emit("forward"))
	back_button.pressed.connect(func(): _eb.route_requested.emit("back"))
	sleep_button.pressed.connect(func(): _eb.sleep_requested.emit())
	save_button.pressed.connect(func(): _eb.save_requested.emit(0))
	load_button.pressed.connect(func(): _eb.load_requested.emit(0))
	clear_button.pressed.connect(func(): _eb.clear_requested.emit(0))
	west_button.pressed.connect(func(): _select_npc("fisher_west"))
	north_button.pressed.connect(func(): _select_npc("fisher_north"))
	east_button.pressed.connect(func(): _select_npc("fisher_east"))
	_refresh()

func _refresh() -> void:
	day_label.text = "Day %d" % _gs.current_day
	food_label.text = "Food: %d" % _gs.food
	dream_label.text = "Dream" if _gs.is_dream_today else "Reality"
	route_label.text = "%s / %d" % [_gs.current_route, _gs.route_distance]
	npc_label.text = "NPC: %s" % (_gs.selected_npc_id if not _gs.selected_npc_id.is_empty() else "-")
	talk_button.disabled = _gs.selected_npc_id.is_empty()
	rescue_button.disabled = _gs.selected_npc_id.is_empty()
	_update_all_npc_sprites()
	_update_scene_background()

func _select_npc(npc_id: String) -> void:
	_gs.set_selected_npc(npc_id)
	_refresh()

func _update_all_npc_sprites() -> void:
	_update_single_npc_sprite(npc_west_sprite, "fisher_west")
	_update_single_npc_sprite(npc_north_sprite, "fisher_north")
	_update_single_npc_sprite(npc_east_sprite, "fisher_east")

func _update_single_npc_sprite(sprite: TextureRect, npc_id: String) -> void:
	if sprite == null:
		return
	var state: int = _gs.get_npc_state(npc_id, 0)
	var state_map: Dictionary = NPC_STATE_SPRITES.get(npc_id, {})
	var path: String = state_map.get(state, "")
	if not path.is_empty() and ResourceLoader.exists(path):
		sprite.texture = load(path)
		sprite.visible = true
	else:
		sprite.visible = false

func _on_npc_state_changed(npc_id: String, _state_value: int) -> void:
	_refresh()

func _update_scene_background() -> void:
	if scene_background == null:
		return
	if _gs.is_dream_today:
		var dream_path: String = "res://assets/sprites/背景/dream_sunset.png"
		if ResourceLoader.exists(dream_path):
			scene_background.texture = load(dream_path)
	else:
		var main_path: String = "res://assets/sprites/背景/beach_day_main.png"
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

func _on_dialogue_displayed(speaker_name: String, text: String, dream_only: bool) -> void:
	if dialogue_panel == null or dialogue_speaker == null or dialogue_text == null:
		return
	dialogue_speaker.text = speaker_name
	dialogue_text.text = text
	dialogue_panel.visible = true
	# Auto-hide dialogue after a few seconds
	var timer := get_tree().create_timer(4.0)
	timer.timeout.connect(func():
		if is_instance_valid(dialogue_panel):
			dialogue_panel.visible = false
	)
