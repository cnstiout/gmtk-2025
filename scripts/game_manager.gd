extends Node

@onready var main_menu: Control = %MainMenu
@onready var scene_level_1: String = "uid://1shqohj0xof7"

var current_scene: Node

func _ready() -> void:
	Events.switch_level.connect(_on_switch_level)
	current_scene = main_menu

func _on_switch_level(level_id: int) -> void:
	start_level(level_id)

func start_level(_level_id: int) -> void:
	SceneTransition.switch_to_scene(scene_level_1)
