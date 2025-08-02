extends Control


@onready var main_menu_path = "uid://clt13pddeirxi"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel_container: PanelContainer = $PanelContainer

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: TextureButton = %MainMenuButton

signal request_resume

func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	animation_player.play("RESET")

func resume() -> void:
	animation_player.play_backwards("blur")
	await animation_player.animation_finished
	panel_container.hide()

func pause() -> void:
	panel_container.show()
	animation_player.play("blur")

func reset() -> void:
	self.hide()
	animation_player.play("RESET")

func _on_resume_button_pressed() -> void:
	request_resume.emit()

func _on_restart_button_pressed() -> void:
	Events.restart_current_level.emit()


func _on_main_menu_button_pressed() -> void:
	Events.request_main_menu.emit()
