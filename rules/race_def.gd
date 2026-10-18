class_name RaceDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var speed: int = 30
@export var creature_type: String = ""
@export var size: String = "Medium"
@export var traits: Array[TraitDef] = []
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var model_scene: PackedScene
@export_group("Proficiencies")
@export_flags("Light", "Medium", "Heavy", "Shields") var armor_profs: int = 0
@export_flags("Simple", "Martial") var weapon_categories: int = 0
@export var specific_weapons: Array[String] = []
