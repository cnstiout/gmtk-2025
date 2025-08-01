extends Control

@onready var main_menu_path = "uid://clt13pddeirxi"

@onready var replay_button: Button = %ReplayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	replay_button.pressed.connect(_on_button_replay_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)

func _on_button_replay_pressed() -> void:
	Events.restart_current_level.emit()

func _on_button_quit_pressed() -> void:
	Events.request_main_menu.emit()

func reset() -> void:
	self.hide()
