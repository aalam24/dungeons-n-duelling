class_name Skills
extends RefCounted

const ALL := [
	["Athletics", "STR"],
	["Acrobatics", "DEX"], ["Sleight of Hand", "DEX"], ["Stealth", "DEX"],
	["Arcana", "INT"], ["History", "INT"], ["Investigation", "INT"],
	["Nature", "INT"], ["Religion", "INT"],
	["Animal Handling", "WIS"], ["Insight", "WIS"], ["Medicine", "WIS"],
	["Perception", "WIS"], ["Survival", "WIS"],
	["Deception", "CHA"], ["Intimidation", "CHA"],
	["Performance", "CHA"], ["Persuasion", "CHA"],
]

static func ability_of(skill: String) -> String:
	for entry in ALL:
		if entry[0] == skill:
			return entry[1]
	return ""
	
