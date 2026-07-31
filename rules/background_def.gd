class_name BackgroundDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var skills: Array[String] = []
@export var tool_prof: Array[String] = [] # prob not needed for now, just adding for later
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var starting_equipment: Array[String] = []
