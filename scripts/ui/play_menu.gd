extends Control

@onready var new_char_button: Button = %NewCharButton
@onready var load_char_button: Button = %LoadCharButton
@onready var sandbox_button: Button = %SandboxButton
@onready var survival_button: Button = %SurvivalButton
@onready var back_button: Button = %BackButton

func _ready() -> void:
	new_char_button.pressed.connect(func(): SceneManager.goto("character_creation"))
	load_char_button.pressed.connect(func(): SceneManager.goto("load_character"))
	sandbox_button.pressed.connect(func(): SceneManager.goto("sandbox"))
	survival_button.pressed.connect(func(): SceneManager.goto("survival"))
	back_button.pressed.connect(func(): SceneManager.goto("main_menu"))
	new_char_button.grab_focus()
