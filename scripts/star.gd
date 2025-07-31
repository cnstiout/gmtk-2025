extends Node3D

@export var text: String = "Bonjour Monde!"
@export var radius: float = 2.0    # Distance du centre de la sphère
@export var speed: float = 0.5     # Vitesse de rotation (rad/s)

var labels: Array = []

func _ready():
	# Instanciation des Label3D, un par caractère
	for c in text:
		var lbl = Label3D.new()
		lbl.text = c
		# Toujours face à la caméra
		lbl.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		add_child(lbl)
		labels.append(lbl)
	_position_labels()

func _position_labels():
	var n = labels.size()
	for i in range(n):
		var angle = float(i) / n * TAU
		# Position sur le cercle équatorial
		var pos = Vector3(radius * cos(angle), 0, radius * sin(angle))
		labels[i].translation = pos
		# Oriente chaque label vers le centre
		labels[i].look_at(Vector3.ZERO, Vector3.UP)
		# Corrige l'orientation (face vers l'extérieur)
		labels[i].rotate_y(PI)

func _process(delta):
	# Tourne tout le pivot (Node3D) : les labels suivent
	rotate_y(speed * delta)
