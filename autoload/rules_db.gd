extends Node

var classes: Dictionary = {}
var races: Dictionary = {}
var backgrounds: Dictionary = {}
var spells: Dictionary = {}
var monsters: Dictionary = {}

func _ready() -> void:
	classes = _load_dir("res://rules/classes/")
	races = _load_dir("res://rules/races/")
	backgrounds = _load_dir("res://rules/backgrounds/")
	spells = _load_dir("res://rules/spells/")
	monsters = _load_dir("res://rules/monsters/")
	
func _load_dir(path: String) -> Dictionary: 
	var out := {}
	for file in DirAccess.get_files_at(path):
		file = file.trim_suffix(".remap")
		if not file.ends_with(".tres"):
			continue
		var res: Resource = load(path + file)
		if res and res.id != "":
			out[res.id] = res
		else:
			push_warning("Skipping resource with no id: %s" % file)
	return out
