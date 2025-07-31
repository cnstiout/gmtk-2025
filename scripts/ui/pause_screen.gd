extends Control


@onready var main_menu_path = "uid://clt13pddeirxi"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var panel_container: PanelContainer = $PanelContainer

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	animation_player.play("RESET")

func _process(_delta: float) -> void:
	testEsc()

func resume() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	await animation_player.animation_finished
	panel_container.hide()

func pause() -> void:
	get_tree().paused = true
	panel_container.show()
	animation_player.play("blur")

func testEsc() -> void:
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused:
			resume()
		else:
			pause()


func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	resume()
	get_tree().call_deferred("reload_current_scene")


func _on_main_menu_button_pressed() -> void:
	SceneTransition.switch_to_scene(main_menu_path)
