extends Camera3D

@export_group("Orbit Around Pivot")
@export var pivot_path: NodePath                 # chemin vers le Node3D pivot
@export var orbit_radius: float = 5.0            # distance au pivot
@export var orbit_speed_deg: float = 10.0         # °/s autour du pivot (azimut)
@export var orbit_height: float = 0.0             # offset vertical relatif au pivot (y)

@export_group("Self Spin (Roll)")
@export var enable_roll: bool = false             # activer le roll sur l'axe de vue
@export var roll_speed_deg: float = 60.0          # °/s pour le roll

var _pivot: Node3D
var _current_angle_deg: float = 0.0
var _accumulated_roll_deg: float = 0.0

func _ready() -> void:
	if pivot_path != NodePath():
		_pivot = get_node_or_null(pivot_path) as Node3D
	if _pivot == null:
		push_warning("Pivot introuvable : vérifie que 'pivot_path' pointe bien vers un Node3D.")
		return

	# Placement initial
	_update_orbit(0.0)
	_apply_look_and_roll(0.0)

func _process(delta: float) -> void:
	if _pivot == null:
		return

	# Mise à jour de l'angle d'orbite (boucle 0-360)
	_current_angle_deg = fmod(_current_angle_deg + orbit_speed_deg * delta, 360.0)
	_update_orbit(delta)

	# Appliquer regard + roll
	_apply_look_and_roll(delta)

func _update_orbit(delta: float) -> void:
	var ang_rad = deg_to_rad(_current_angle_deg)
	var x = cos(ang_rad) * orbit_radius
	var z = sin(ang_rad) * orbit_radius
	var target_pos = _pivot.global_transform.origin + Vector3(x, orbit_height, z)
	global_transform.origin = target_pos

func _apply_look_and_roll(delta: float) -> void:
	# Toujours regarder le pivot
	var to_pivot = (_pivot.global_transform.origin - global_transform.origin).normalized()
	# Base sans roll
	var base_basis = Basis().looking_at(to_pivot, Vector3.UP)

	if enable_roll:
		# Accumuler le roll
		_accumulated_roll_deg = fmod(_accumulated_roll_deg + roll_speed_deg * delta, 360.0)
		var roll_rad = deg_to_rad(_accumulated_roll_deg)
		# Appliquer roll autour de l'axe de vue (forward)
		var forward = to_pivot
		# Calculer un "up" roulé : prend l'up global et le fait tourner autour de l'avant
		var rolled_up = Vector3.UP.rotated(forward, roll_rad).normalized()
		global_transform.basis = Basis().looking_at(forward, rolled_up)
	else:
		global_transform.basis = base_basis
