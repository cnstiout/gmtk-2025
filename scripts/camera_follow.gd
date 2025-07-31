extends PathFollow3D

var speed: float = 0.05
var boost_amount: float = 0.02

func _ready() -> void:
	Events.boost_picked_up.connect(_on_boost_picked_up)
	Events.wall_hit.connect(_on_wall_hit)

func _process(delta: float) -> void:
	progress_ratio += speed * delta
	

# Change your speed, negative number slow you down
func boost(amount:int = 1):
	if amount != 0:
		speed += boost_amount * amount
		if amount > 0:
			print("Boost!!!")
		else:
			print("Speed down...")
	
func _on_boost_picked_up(_xform: Transform3D):
	boost(1)
	

func _on_wall_hit():
	boost(-1)
