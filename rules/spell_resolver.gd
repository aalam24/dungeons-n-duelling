class_name SpellResolver
extends RefCounted

static func damage_for(spell: SpellDef, caster: CharacterSheet, slot_level: int) -> String:
	var dice := spell.damage_dice
	if slot_level > spell.level and spell.upcast_dice != "":
		pass #add (slot_level - spell.level) * upcast_die
	return dice
	
static func save_dc(spell: SpellDef, caster: CharacterSheet) -> int:
	var cls: ClassDef = RulesDB.classes.get(caster.char_class)
	return 8 + caster.prof_bonus() + caster.modifier(cls.spellcasting_ability)
	
		
