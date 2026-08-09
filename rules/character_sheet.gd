class_name CharacterSheet
extends Resource

@export var char_name: String = ""
@export var char_class: String = ""
@export var race: String = ""
@export var background: String = ""
@export var level: int = 1

@export var base_abilities: Dictionary = {
	"STR": 8, "DEX": 8, "CON": 8,
	"INT": 8, "WIS": 8, "CHA": 8
}

@export var asi_major: String = "" # should be +2
@export var asi_minor: String = "" # should be +1
@export var chosen_class_skills: Array[String] = []
@export var known_cantrips: Array[String] = [] #spell ids
@export var known_spells: Array[String] = []

func ability_score(key: String) -> int:
	var score: int = base_abilities[key]
	if key == asi_major:
		score += 2
	if key == asi_minor:
		score += 1
	return score

func modifier(key: String) -> int:
	return floori((ability_score(key) - 10) / 2.0)
	
func prof_bonus() -> int:
	return floori((level - 1) / 4.0) + 2

func proficient_skills() -> Array[String]:
	var out: Array[String]
	var bg: BackgroundDef = RulesDB.backgrounds.get(background)
	if bg:
		out.append_array(bg.skills)
	for skill in chosen_class_skills:
		if skill not in out:
			out.append(skill)
	return out
