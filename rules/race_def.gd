class_name RaceDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var speed: int = 30
@export var size: String = "Medium"
@export var traits: Array[String] = []
@export_multiline var description: String = ""
@export var model_scene: PackedScene
