extends Node3D

@export var text: String = "HELLOWORLD -"
@export var radius: float = 2.0    # Distance du centre de la sphère
@export var speed: float = 0.5     # Vitesse de rotation (rad/s)

var labels: Array = []

func _ready():
	# Instancie un Label3D par caractère
	for c in text:
		var lbl = Label3D.new()
		lbl.text = c
		# Billboarding « fixe » sur l'axe Y pour que le texte reste droit
		lbl.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		add_child(lbl)
		labels.append(lbl)
	_position_labels()

func _position_labels():
	var n = labels.size()
	for i in range(n):
		var angle = float(i) / n * TAU
		# Calcule la position sur le cercle (équateur)
		var pos = Vector3(radius * cos(angle), 0, radius * sin(angle))
		# → Utilise `position`, pas `translation`
		labels[i].position = pos
		# Oriente vers le centre de la sphère
		labels[i].look_at(Vector3.ZERO, Vector3.UP)
		# Retournement pour que le texte soit lisible vers l'extérieur
		labels[i].rotate_y(PI)

func _process(delta):
	# Tourne tout le Node3D (le pivot) : les labels suivent
	rotate_y(speed * delta)
