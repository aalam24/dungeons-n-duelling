class_name CreatureStats
extends Resource

func get_display_name() -> String:
	return "Creature"

func ability_scores(_key: String) -> int:
	return 10
	
func modifier(key: String) -> int:
	return floori((ability_scores(key) - 10) / 2.0)
	
func prof_bonus() -> int:
	return 2
	
func max_hp() -> int:
	return 1
	
func armor_class() -> int:
	return 10 + modifier("DEX")
	
func save_bonus(key: String) -> int:
	return modifier(key)

func initiative_bonus() -> int:
	return modifier("DEX")
	
func speed_ft() -> int:
	return 30
	
