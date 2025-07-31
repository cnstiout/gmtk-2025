extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var current_scene:Node = null

func _ready() -> void:
	current_scene = get_tree().current_scene

func switch_to_scene(scene_path) -> void:
	call_deferred("_deferred_switch_scene", scene_path)

func _deferred_switch_scene(scene_path):
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().current_scene.free()
	var new_scene:PackedScene = load(scene_path)
	get_tree().paused = true
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	animation_player.play_backwards("fade_out")
	await animation_player.animation_finished
	get_tree().paused = false
	
