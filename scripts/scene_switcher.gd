extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var help_menu: Control = %HelpMenu

signal transition_finished
signal continue_pressed

var main_scene: Node = null
var current_level: Node3D = null

var ready_to_continue = false

var in_transition = false

func _ready() -> void:
	main_scene = get_tree().current_scene
	help_menu.continue_button.pressed.connect(_on_button_continue_pressed)

func _on_button_continue_pressed():
	if ready_to_continue:
		continue_pressed.emit()

func start_level(level_path) -> void:
	var new_level: PackedScene = load(level_path)
	var new_level_node: Node3D = new_level.instantiate()
	main_scene.change_current_level_node(new_level_node)

func switch_to_scene(scene_path) -> void:
	call_deferred("_deferred_switch_scene", scene_path)

func _deferred_switch_scene(scene_path):
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().current_scene.free()
	var new_scene:PackedScene = load(scene_path)
	get_tree().paused = true
	main_scene = new_scene.instantiate()
	get_tree().root.add_child(main_scene)
	get_tree().current_scene = main_scene
	animation_player.play_backwards("fade_out")
	await animation_player.animation_finished
	get_tree().paused = false

# Fade the screen to black and emit signal when the transition is finished
func fade_to_black(reversed: bool, show_help_menu: bool) -> void:
	if !in_transition:
		in_transition = true
		if show_help_menu:
			if !reversed:
				animation_player.play("fade_out_help_menu")
				await animation_player.animation_finished
				help_menu.continue_button.grab_focus()
				ready_to_continue = true
			else:
				animation_player.play_backwards("fade_out_help_menu")
				await animation_player.animation_finished
				help_menu.continue_button.release_focus()
				animation_player.play("RESET")
				ready_to_continue = false
				
		else:
			if !reversed:
				animation_player.play("fade_out")
			else:
				animation_player.play_backwards("fade_out")
				await animation_player.animation_finished
				help_menu.continue_button.release_focus()
				animation_player.play("RESET")
			
			await animation_player.animation_finished
		
		in_transition = false
		transition_finished.emit()
