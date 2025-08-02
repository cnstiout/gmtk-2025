extends TextureButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func animate_hover() -> void:
	animation_player.play("hover")


func animate_hover_exit() -> void:
	animation_player.play_backwards("hover")
