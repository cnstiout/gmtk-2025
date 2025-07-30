extends PathFollow3D

var speed: float = 0.1
var boost_amount: float = 0.2

func _ready() -> void:
	Events.boost_picked_up.connect(_on_boost_picked_up)

func _process(delta: float) -> void:
	progress_ratio += speed * delta
	

func _on_boost_picked_up():
	speed += boost_amount
