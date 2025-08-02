extends Node

@onready var main_menu: Control = %MainMenu
@onready var pause_menu: Control = %PauseMenu
@onready var gameover_screen: Control = %GameoverScreen
@onready var menu_3d: Node3D = %Menu3D

@onready var scene_level_1: String = "uid://1shqohj0xof7"
@onready var current_level: Node = $CurrentLevel
@onready var scene_transition: CanvasLayer = %SceneTransition

var current_scene: Node

var is_pause_menu_acc: bool = false
var game_paused = false

var highscore:int = 0

func _ready() -> void:
	Events.restart_current_level.connect(restart_current_level)
	Events.request_main_menu.connect(back_to_main_menu)
	
	Events.new_run_score.connect(change_highscore)
	Events.player_died.connect(_on_player_died)
	
	pause_menu.request_resume.connect(resume_game)
	main_menu.start_level.connect(_on_switch_level)
	current_scene = main_menu

func _input(event: InputEvent) -> void:
	if is_pause_menu_acc && event.is_action_pressed("esc"):
		if game_paused:
			resume_game()
		else:
			pause_game()

func change_highscore(new_score: int) -> void:
	if new_score > highscore:
		highscore = new_score
		gameover_screen.change_highscore(highscore)

func resume_game() -> void:
	get_tree().paused = false
	pause_menu.resume()
	game_paused = false

func pause_game() -> void:
	get_tree().paused = true
	pause_menu.pause()
	game_paused = true
	

func _on_switch_level(level_path: String) -> void:
	start_level(level_path)

func start_level(level_path: String) -> void:
	scene_transition.fade_to_black(false)
	await scene_transition.transition_finished
	
	_hide_main_menu()
	var new_level: PackedScene = load(level_path)
	var new_level_node: Level = new_level.instantiate()
	new_level_node.name = "Level"
	_change_current_level_node(new_level_node)
	
	scene_transition.fade_to_black(true)
	await scene_transition.transition_finished
	
	new_level_node.start_countdown()
	is_pause_menu_acc = true

func _on_player_died() -> void:
	show_game_over()

func restart_current_level() -> void:
	if game_paused:
		resume_game()
	gameover_screen.reset()
	current_level.get_child(0).restart()

func show_game_over() -> void:
	gameover_screen.show()

func back_to_main_menu() -> void:
	is_pause_menu_acc = false
	
	scene_transition.fade_to_black(false)
	await scene_transition.transition_finished
	
	_clear_level()
	gameover_screen.reset()
	pause_menu.reset()
	get_tree().paused = false
	_show_main_menu()
	
	scene_transition.fade_to_black(true)
	await scene_transition.transition_finished

func _clear_level() -> void:
	for i in current_level.get_child_count():
		current_level.get_child(i).call_deferred("queue_free")

func _change_current_level_node(level: Node3D) -> void:
	_clear_level()
	current_level.add_child(level)

func _show_main_menu() -> void:
	main_menu.show()
	menu_3d.show_menu()

func _hide_main_menu() -> void:
	main_menu.hide()
	menu_3d.hide_menu()
