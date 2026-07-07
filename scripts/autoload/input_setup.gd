extends Node

func _ready() -> void:
	_register("move_forward", KEY_W)
	_register("move_back", KEY_S)
	_register("talk", KEY_E)
	_register("rescue", KEY_R)
	_register("sleep", KEY_SPACE)
	_register("save", KEY_F5)
	_register("load", KEY_F8)


func _register(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)