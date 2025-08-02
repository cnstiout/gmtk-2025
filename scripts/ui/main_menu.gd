extends Control

@onready var play_button: TextureButton = %PlayButton
@onready var quit_button: Button = %QuitButton

@onready var scene_level_1: String = "uid://1shqohj0xof7"

signal start_level(level_path: String)

func _ready() -> void:
	play_button.pressed.connect(_on_button_play_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)
	play_button.mouse_entered.connect(_on_play_button_hovered)
	play_button.mouse_exited.connect(_on_play_button_hover_exit)

func _on_button_play_pressed() -> void:
	start_level.emit(scene_level_1)

func _on_button_quit_pressed() -> void:
	get_tree().quit()

func _on_play_button_hovered() -> void:
	pass

func _on_play_button_hover_exit() -> void:
	pass
	
