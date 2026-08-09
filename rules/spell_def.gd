class_name SpellDef
extends Resource

enum School {ABJURATION, CONJURATION, DIVINATION, ENCHANTMENT, 
EVOCATION, ILLUSION, NECROMANCY, TRANSMUTATION}
enum TargetMode {SELF, SINGLE, SPHERE, CONE, LINE, CUBE}
enum SaveEffect {NONE, HALF, NEGATE}

@export var id: String = ""
@export var display_name: String = ""
@export var level: int = 1 # 0 = cantrips
@export var school: School = School.EVOCATION
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Casting")
@export var casting_time: String = "1 action"
@export var range_ft: int = 0
@export var duration: String = "Instantaneous"
@export var concentration: bool = false
@export var ritual: bool = false

@export_group("Targetting")
@export var target_mode: TargetMode = TargetMode.SINGLE
@export var area_size_ft: int = 0 # radius/length/edge

@export_group("Resolution")
@export var attack_roll: bool = false
@export var save_ability: String = "" # "DEX" or "STR" or "" if none
@export var save_effect: SaveEffect = SaveEffect.NONE
@export var damage_dice: String = ""
@export var damage_type: String = ""
@export var upcast_dice: String = "" # 1d6 per level 
