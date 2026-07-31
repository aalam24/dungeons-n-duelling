extends Control

@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.grab_focus()

func _on_play_pressed() -> void:
	SceneManager.goto("play_menu")
func _on_options_pressed() -> void:
	SceneManager.goto("options")
func _on_quit_pressed() -> void:
	get_tree().quit()
	
