extends Control

@onready var main_menu_path = "uid://clt13pddeirxi"

@onready var replay_button: Button = %ReplayButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	replay_button.pressed.connect(_on_button_replay_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)

func _on_button_replay_pressed() -> void:
	get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
	SceneTransition.switch_to_scene(main_menu_path)
