extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal transition_finished

var main_scene: Node = null
var current_level: Node3D = null

func _ready() -> void:
	main_scene = get_tree().current_scene

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
func fade_to_black(reversed: bool) -> void:
	if !reversed:
		animation_player.play("fade_out")
	else:
		animation_player.play_backwards("fade_out")
	
	await animation_player.animation_finished
	transition_finished.emit()
