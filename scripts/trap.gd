extends Area3D

@onready var trap_sfx: AudioStreamPlayer = $TrapSFX

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node3D) -> void:
	Events.trap_triggered.emit(global_transform)
	trap_sfx.play()
	await trap_sfx.finished
	queue_free()
