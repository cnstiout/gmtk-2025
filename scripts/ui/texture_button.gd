extends TextureButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	mouse_entered.connect(animate_hover)
	mouse_exited.connect(animate_hover_exit)

func animate_hover() -> void:
	animation_player.play("hover")


func animate_hover_exit() -> void:
	animation_player.play_backwards("hover")
