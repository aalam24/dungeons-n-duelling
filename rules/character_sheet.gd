class_name CharacterSheet
extends CreatureStats

const SCHEMA_VERSION := 1

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
@export var uid: String = ""
@export var hp_rolls: Array[int] = []


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
	
func armor_profs() -> int:
	var flags:= 0
	var cls: ClassDef = RulesDB.classes.get(char_class)
	var rc: RaceDef = RulesDB.races.get(race)
	if cls:
		flags |= cls.armor_profs
	if rc:
		flags |= rc.armor_profs
	return flags
	
func weapon_categories() -> int:
	var flags:= 0
	var cls: ClassDef = RulesDB.classes.get(char_class)
	var rc: RaceDef = RulesDB.races.get(race)
	if cls:
		flags |= cls.weapon_categories
	if rc:
		flags |= rc.weapon_categories
	return flags

func specific_weapons() -> Array[String]:
	var seen:= {}
	var cls: ClassDef = RulesDB.classes.get(char_class)
	var rc: RaceDef = RulesDB.races.get(race)
	for source in [cls, rc]:
		if source:
			for w in source.specific_weapons:
				seen[w] = true
	var out: Array[String] = []
	out.assign(seen.keys())
	return out
	
func is_proficient_with_weapon(weapon_id: String, category: int) -> bool:
	return (weapon_categories() & category) != 0 or weapon_id in specific_weapons()
	
func is_proficient_with_armor(kind: int) -> bool:
	return (armor_profs() & kind) != 0

func to_dict() -> Dictionary:
	return {
		"version": SCHEMA_VERSION,
		"uid": uid,
		"char_name": char_name,
		"char_class": char_class,
		"race": race,
		"background": background,
		"level": level,
		"base_abilities": base_abilities.duplicate(),
		"asi_major": asi_major,
		"asi_minor": asi_minor,
		"chosen_class_skills": chosen_class_skills.duplicate(),
		"known_cantrips": known_cantrips.duplicate(),
		"known_spells": known_spells.duplicate(),
		"hp_rolls": hp_rolls.duplicate(),
	}

static func from_dict(d: Dictionary) -> CharacterSheet:
	var s:= CharacterSheet.new()
	s.uid = str(d.get("uid", ""))
	s.char_name = str(d.get("char_name", ""))
	s.char_class = _known_id(d.get("char_class", ""), RulesDB.classes)
	s.race = _known_id(d.get("race", ""), RulesDB.races)
	s.char_class = _known_id(d.get("char_class", ""), RulesDB.classes)
	s.level = clampi(int(d.get("level", 1)), 1, 20)
	
	var rolls = d.get("hp_rolls", [])
	if rolls is Array:
		for r in rolls:
			s.hp_rolls.append(clampi(int(r), 1, 12))
	
	var abil = d.get("base_abilities", {})
	if abil is Dictionary:
		for key in s.base_abilities:
			s.base_abilities[key] = clampi(int(abil.get(key, 8)), 1, 20)
	
	s.asi_major = _known_key(d.get("asi_major", ""), s.base_abilities)
	s.asi_minor = _known_key(d.get("asi_minor", ""), s.base_abilities)
	s.chosen_class_skills.assign(_string_array(d.get("chosen_class_skills", [])))
	s.known_cantrips.assign(_string_array(d.get("known_cantrips", [])))
	s.known_spells.assign(_string_array(d.get("known_spells", [])))
	return s	
	
	
static func _known_id(v, table: Dictionary) -> String:
	var id:= str(v)
	if id != "" and not table.has(id):
		push_warning("Unknown id in save file: %s" % id)
		return ""
	return id
	
static func _known_key(v, table: Dictionary) -> String:
	var k := str(v)
	return k if table.has(k) else ""
	
static func _string_array(v) -> Array[String]:
	var out: Array[String] = []
	if v is Array: 
		for x in v:
			out.append(str(x))
	return out
	
func validation_errors() -> Array[String]:
	var errors: Array[String] = []
	if char_name.strip_edges() == "":
		errors.append("Enter a name")

	var cls: ClassDef = RulesDB.classes.get(char_class)
	if cls == null:
		errors.append("Choose a class")
	if race == "":
		errors.append("Choose a race")
	if background == "":
		errors.append("Choose a background")
		
	if cls:
		var granted := background_skills()
		var pickable := 0
		for s in cls.skill_choices:
			if s not in granted:
				pickable += 1
		var need:= mini(cls.skill_choice_count, pickable)
		if chosen_class_skills.size() < need:
			errors.append("Choose %d more skill(s)" % need)

	var left := PointBuy.BUDGET - PointBuy.total_spent(base_abilities)
	if left > 0:
		errors.append("Spend all ability points (%d left)" % left)
	if asi_major == "" or asi_minor == "":
		errors.append("Assign your +2 and +1")

	if cls and cls.spellcasting_ability != "":
		var need_c := mini(cls.cantrips_known_at_1, _available_spells(cls, 0))
		var need_s := mini(cls.spells_known_at_1, _available_spells(cls, 1))
		if known_cantrips.size() < need_c:
			errors.append("Choose %d more cantrip(s)" % (need_c - known_cantrips.size()))
		if known_spells.size() < need_s:
			errors.append("Choose %d more 1st-level spell(s)" % (need_s - known_spells.size()))
	return errors

func is_complete() -> bool:
	return validation_errors().is_empty()

func _available_spells(cls: ClassDef, spell_level: int) -> int:
	var n := 0
	for s in cls.spell_list:
		if s and s.level == spell_level:
			n += 1
	return n
	
func background_skills() -> Array[String]:
	var out: Array[String] = []
	var bg: BackgroundDef = RulesDB.backgrounds.get(background)
	if bg:
		out.assign(bg.skills)
	return out

func skill_bonus(skill: String) -> int: 
	var ability := Skills.ability_of(skill)
	if ability == "":
		return 0
	var bonus := modifier(ability)
	if skill in proficient_skills():
		bonus += prof_bonus()
	return bonus
	
func max_hp() -> int:
	var cls: ClassDef = RulesDB.classes.get(char_class)
	if cls == null:
		return 0
	var con := modifier("CON")
	var total := maxi(1, cls.hit_die + con)
	for roll in hp_rolls:
		total += max(1, roll + con)
	return total
	
func initiative_bonus() -> int:
	return modifier("DEX") + _initiative_extras()
	
func _initiative_extras() -> int:
	return 0
	
func get_display_name() -> String:
	return char_name if char_name != "" else "Unnamed"
	
func speed_ft() -> int:
	var rc: RaceDef = RulesDB.races.get(race)
	return rc.speed if rc else 30

func save_bonuses(key: String) -> int:
	var cls: ClassDef = RulesDB.classes.get(char_class)
	var bonus := modifier(key)
	if cls and key in cls.saving_throws:
		bonus += prof_bonus()
	return bonus
	
