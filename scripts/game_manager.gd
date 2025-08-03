extends Node

@onready var main_menu: Control = %MainMenu
@onready var pause_menu: Control = %PauseMenu
@onready var gameover_screen: Control = %GameoverScreen
@onready var menu_3d: Node3D = %Menu3D

@onready var scene_level_1: String = "uid://1shqohj0xof7"
@onready var current_level: Node = $CurrentLevel
@onready var scene_transition: CanvasLayer = %SceneTransition


@onready var new_level: PackedScene = preload("uid://1shqohj0xof7")



var current_scene: Node

var is_pause_menu_acc: bool = false
var game_paused = false

var highscore:int = 0

var starting_level: bool = false
var going_back_menu: bool = false

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
	if !starting_level && !going_back_menu:
		start_level(level_path)

func start_level(_level_path: String) -> void:
	starting_level = true
	scene_transition.fade_to_black(false, true)
	await scene_transition.transition_finished
	
	_hide_main_menu()
	var new_level_node: Level = new_level.instantiate()
	new_level_node.name = "Level"
	_change_current_level_node(new_level_node)
	if !new_level_node.is_node_ready():
		await new_level_node.ready
	
	await scene_transition.continue_pressed
	
	scene_transition.fade_to_black(true, true)
	await scene_transition.transition_finished
	
	new_level_node.start_countdown()
	is_pause_menu_acc = true
	starting_level = false

func _on_player_died() -> void:
	show_game_over()

func restart_current_level() -> void:
	if game_paused:
		resume_game()
	gameover_screen.reset()
	current_level.get_child(0).restart()
	is_pause_menu_acc = true

func show_game_over() -> void:
	is_pause_menu_acc = false
	gameover_screen.show()

func back_to_main_menu() -> void:
	if going_back_menu:
		return
	going_back_menu = true
	is_pause_menu_acc = false
	
	scene_transition.fade_to_black(false, false)
	await scene_transition.transition_finished
	
	_clear_level()
	gameover_screen.reset()
	pause_menu.reset()
	get_tree().paused = false
	_show_main_menu()
	
	scene_transition.fade_to_black(true, false)
	await scene_transition.transition_finished
	going_back_menu = false

func _clear_level() -> void:
	for i in current_level.get_child_count():
		current_level.get_child(i).call_deferred("queue_free")
		await current_level.tree_exited

func _change_current_level_node(level: Node3D) -> void:
	_clear_level()
	current_level.add_child(level)

func _show_main_menu() -> void:
	main_menu.show()
	main_menu.reset()
	menu_3d.show_menu()

func _hide_main_menu() -> void:
	main_menu.hide()
	menu_3d.hide_menu()
