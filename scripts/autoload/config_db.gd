extends Node
class_name ConfigDB

const GAME_CONFIG_PATH := "res://data/config/game_config.tres"
const CHARACTER_DIR := "res://data/characters"
const ROUTE_DIR := "res://data/routes"
const DIALOGUE_DIR := "res://data/dialogues"
const ENDING_DIR := "res://data/endings"

var game_config: Resource
var characters: Dictionary = {}
var routes: Dictionary = {}
var dialogues: Dictionary = {}
var endings: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	game_config = _load_resource(GAME_CONFIG_PATH)
	characters = _load_folder(CHARACTER_DIR)
	routes = _load_folder(ROUTE_DIR)
	dialogues = _load_folder(DIALOGUE_DIR)
	endings = _load_folder(ENDING_DIR)


func get_game_config() -> Resource:
	return game_config


func get_character(character_id: String) -> Variant:
	return characters.get(character_id)


func get_route(route_id: String) -> Variant:
	return routes.get(route_id)


func get_dialogue(dialogue_id: String) -> Variant:
	return dialogues.get(dialogue_id)


func get_ending(ending_id: String) -> Variant:
	return endings.get(ending_id)


func has_character(character_id: String) -> bool:
	return characters.has(character_id)


func has_route(route_id: String) -> bool:
	return routes.has(route_id)


func has_dialogue(dialogue_id: String) -> bool:
	return dialogues.has(dialogue_id)


func has_ending(ending_id: String) -> bool:
	return endings.has(ending_id)


func _load_folder(folder_path: String) -> Dictionary:
	var result: Dictionary = {}
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var extension := file_name.get_extension().to_lower()
			if extension in ["tres", "res", "json"]:
				var key := file_name.get_basename()
				var full_path := "%s/%s" % [folder_path, file_name]
				result[key] = _load_resource_or_variant(full_path, extension)
		file_name = dir.get_next()
	dir.list_dir_end()
	return result


func _load_resource(path: String) -> Resource:
	if ResourceLoader.exists(path):
		return load(path)
	return null


func _load_resource_or_variant(path: String, extension: String) -> Variant:
	if extension == "json":
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			return null
		return JSON.parse_string(file.get_as_text())
	return _load_resource(path)

