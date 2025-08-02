extends Control

@onready var play_button: TextureButton = %PlayButton
@onready var quit_button: Button = %QuitButton

@onready var scene_level_1: String = "uid://1shqohj0xof7"

signal start_level(level_path: String)

func _ready() -> void:
	play_button.grab_focus()
	play_button.pressed.connect(_on_button_play_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)

func reset() -> void:
	play_button.grab_focus()
	

func _on_button_play_pressed() -> void:
	start_level.emit(scene_level_1)

func _on_button_quit_pressed() -> void:
	get_tree().quit()
	
