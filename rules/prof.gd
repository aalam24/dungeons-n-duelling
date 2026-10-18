class_name Prof
extends RefCounted

enum Armor {LIGHT = 1, MEDIUM = 2, HEAVY = 4, SHEILDS = 8}
enum Weapon {SIMPLE = 1, MARTIAL = 2}

static func armor_names(flags: int) -> Array[String]:
	var out: Array[String] = []
	for name in Armor.keys():
		if flags & Armor[name]:
			out.append(name.capitalize())
	return out
	
static func weapon_names(flags: int) -> Array[String]:
	var out: Array[String] = []
	for name in Weapon.keys():
		if flags & Weapon[name]:
			out.append(name.capitalize() + " weapons")
	return out
	
