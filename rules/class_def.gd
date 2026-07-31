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
