extends Node

const SCENES := {
	"main_menu": "res://scenes/ui/main_menu.tscn",
	"options": "res://scenes/ui/options.tscn",
	"play_menu": "res://scenes/ui/play_menu.tscn",
	"character_creation": "res://scenes/ui/character_creation.tscn",
	"load_character": "res://scenes/ui/load_character.tscn",
	"sandbox": "res://scenes/game/sandbox.tscn",
	"survival": "res://scenes/game/survival.tscn",
}

func goto(key: String) -> void:
	if key not in SCENES:
		push_error("Unknown scene key: %s" % key)
		return
	var err := get_tree().change_scene_to_file(SCENES[key])
	if err != OK:
		push_error("Failed to load %s (error %d)" % [key, err])
	
