extends TextureButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var is_first_focus:bool = false

func _ready() -> void:
	focus_entered.connect(animate_hover)
	focus_exited.connect(animate_hover_exit)
	mouse_entered.connect(_on_mouse_hover)
	mouse_exited.connect(_on_mouse_exit)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_down") || event.is_action_pressed("ui_up"):
		#if !has_focus() && is_first_focus:
			#grab_focus()

func _on_mouse_hover() -> void:
	if !has_focus():
		grab_focus()

func _on_mouse_exit() -> void:
	pass
	#if has_focus():
		#release_focus()

func animate_hover() -> void:
	animation_player.play("hover")

func animate_hover_exit() -> void:
	animation_player.play_backwards("hover")
