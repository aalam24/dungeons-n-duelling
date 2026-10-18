class_name MonsterDef
extends CreatureStats

@export var id: String = ""
@export var display_name: String = ""
@export var abilities: Dictionary = {
	"STR": 10, "DEX": 10, "CON": 10, "INT": 10, "WIS": 10, "CHA": 10,
}
@export var hit_points: int = 7
@export var ac: int = 12
@export var speed: int = 30
@export var proficiency: int = 2
@export var save_proficiencies: Array[String] = []
@export var icon: Texture2D

func get_display_name() -> String:
	return display_name
	
func ability_scores(key: String) -> int:
	return abilities.get(key, 10)
	
func prof_bonus() -> int:
	return proficiency
	
func max_hp() -> int:
	return hit_points
	
func armor_class() -> int:
	return ac
	
func save_bonus(key: String) -> int:
	return modifier(key) + (proficiency if key in save_proficiencies else 0)
	
func speed_ft() -> int:
	return speed
	
