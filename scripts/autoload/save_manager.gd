extends Node

const SAVE_DIR := "user://save"
const SAVE_FILE_TEMPLATE := "slot_%d.json"
const SAVE_SCHEMA_VERSION := 1

var _gs: Variant


func _ready() -> void:
	_gs = get_node("/root/GameState")


func save_game(slot_id: int) -> bool:
	if _gs == null:
		push_error("SaveManager: GameState not available")
		return false
	if not _ensure_save_dir():
		return false

	var path: String = _slot_path(slot_id)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file for writing: %s" % path)
		return false

	var payload: Dictionary = _gs.to_save_dict()
	payload["schema_version"] = SAVE_SCHEMA_VERSION
	payload["saved_at_unix"] = Time.get_unix_time_from_system()
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return true


func load_game(slot_id: int) -> bool:
	if _gs == null:
		push_error("SaveManager: GameState not available")
		return false
	var path: String = _slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return false

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open save file for reading: %s" % path)
		return false

	var raw_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: invalid save payload in %s" % path)
		return false

	var save_version: int = int(parsed.get("schema_version", 0))
	if save_version > SAVE_SCHEMA_VERSION:
		push_error("SaveManager: save file version %d is newer than expected %d, refusing to load" % [save_version, SAVE_SCHEMA_VERSION])
		return false
	elif save_version < SAVE_SCHEMA_VERSION:
		push_warning("SaveManager: save file version %d is older than expected %d, attempting migration" % [save_version, SAVE_SCHEMA_VERSION])

	_gs.apply_save_dict(parsed)
	return true


func clear_slot(slot_id: int) -> bool:
	var path: String = _slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return true

	var absolute_path: String = ProjectSettings.globalize_path(path)
	return DirAccess.remove_absolute(absolute_path) == OK


func has_save(slot_id: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot_id))


func list_slots() -> Array:
	var slots: Array = []
	var dir: DirAccess = DirAccess.open(SAVE_DIR)
	if dir == null:
		return slots

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var base_name: String = file_name.get_basename()
			if base_name.begins_with("slot_"):
				var slot_text: String = base_name.trim_prefix("slot_")
				if slot_text.is_valid_int():
					slots.append(int(slot_text))
		file_name = dir.get_next()
	dir.list_dir_end()
	slots.sort()
	return slots


func _ensure_save_dir() -> bool:
	var dir: DirAccess = DirAccess.open("user://")
	if dir == null:
		return false
	if not dir.dir_exists("save"):
		return dir.make_dir("save") == OK
	return true


func _slot_path(slot_id: int) -> String:
	return "%s/%s" % [SAVE_DIR, SAVE_FILE_TEMPLATE % slot_id]

