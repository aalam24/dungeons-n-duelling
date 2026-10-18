class_name ClassDef
extends Resource

@export var id: String = "" # ie "wizard"
@export var display_name: String = "" # ie "Wizard (cooler)
@export var hit_die: int = 8 # changes depending on class
@export var primary_abilities: Array[String] = []
@export var saving_throws: Array[String] = [] # only 2 of them
@export var spellcasting_ability: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D # IMPLEMENT LATER
@export var skill_choice_count: int = 2 # amount of skills for class they pick
@export var skill_choices: Array[String] = [] # eligible list of skills 
@export var level_1_features: Array[TraitDef] = []
@export var spell_list: Array[SpellDef] = []
@export var cantrips_known_at_1: int = 0
@export var spells_known_at_1: int = 0
@export_group("Proficiencies")
@export_flags("Light", "Medium", "Heavy", "Shields") var armor_profs: int = 0
@export_flags("Simple", "Martial") var weapon_categories: int = 0
@export var specific_weapons: Array[String] = []
