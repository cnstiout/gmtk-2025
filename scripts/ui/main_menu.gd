extends Control

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_button_play_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)

func _on_button_play_pressed() -> void:
	Events.switch_level.emit(1)

func _on_button_quit_pressed() -> void:
	get_tree().quit()
