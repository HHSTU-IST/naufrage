extends Node
class_name DreamSystem

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _eb: Variant

func _ready() -> void:
	rng.randomize()
	_eb = get_node_or_null("/root/EventBus")

## 每 3 天触发一次梦境日，起始随机偏移
func roll_today() -> bool:
	return (GameState.current_day % 3) == (rng.randi() % 3)

## 进入梦境日，NPC 会说出 dream_only 对话
func enter_dream() -> void:
	GameState.set_dream_today(true)
	if _eb != null:
		_eb.dialogue_displayed.emit("（梦境）", "你陷入了一场奇怪的梦...", true)

## 梦境中对话可能给出额外线索
func get_dream_clue() -> String:
	var clues := ["clue_dream_west", "clue_dream_north", "clue_dream_east"]
	return clues[rng.randi() % clues.size()]