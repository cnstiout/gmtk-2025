@tool
class_name Road
extends Path3D

@onready var boost_pickup_scene = preload("uid://h2pheoljb6ha")
@onready var obstacle_scene = preload("uid://xqn5l3daobv1")
@onready var road_polygon: CSGPolygon3D = $RoadCSGPolygon3D
@onready var boosts: Node = $Boosts

@export_range(3, 13, 2) var nb_lane: int = 3:
	set(value):
		nb_lane = value
		generate_track()
@export var lane_width: float = 1
@export var road_thickness: float = 0.1
@export var boosts_road_offset:float = 0.2

var obst_spwn_delay: float = 1.0

@export var nb_boost: int = 3:
	set(value):
		nb_boost = value
		clear_boosts()
		spawn_random_boosts(nb_boost)

func _ready() -> void:
	Events.boost_picked_up.connect(_on_boost_picked_up)

func generate_track() -> void:
	if road_polygon:
		var track_polygon: PackedVector2Array
		track_polygon.append(Vector2(-(lane_width * nb_lane) / 2, 0.0))
		track_polygon.append(Vector2((lane_width * nb_lane) / 2, 0.0))
		track_polygon.append(Vector2((lane_width * nb_lane) / 2, -road_thickness))
		track_polygon.append(Vector2(-(lane_width * nb_lane) / 2, -road_thickness))
		print(track_polygon)
		road_polygon.polygon = track_polygon

func spawn_random_boosts(p_nb_boost: int) -> void:
	if !is_node_ready():
		await ready
	boost_pickup_scene = load("uid://h2pheoljb6ha")
	for i in p_nb_boost:
		var rand_lane: int = randi_range(0, nb_lane - 1) - (nb_lane / floor(2))
		var track_position: float = randf() * curve.get_baked_length()
		
		var new_transform = curve.sample_baked_with_rotation(track_position, false, true)
		new_transform = new_transform.translated(new_transform.basis.y * boosts_road_offset)
		new_transform = new_transform.translated(new_transform.basis.x * (rand_lane * lane_width))
		var boost_position = global_transform * new_transform
		
		#boost_position.x += rand_lane * lane_width
		
		var new_boost = boost_pickup_scene.instantiate()
		new_boost.global_transform = boost_position
		#new_boost.transform = align_with_y(new_boost.basis, curve.sample_baked_up_vector(track_position))
		#new_boost.position = boost_position
		#new_boost.position.x += rand_lane * lane_width
		#await child_entered_tree
		boosts.add_child(new_boost)
		new_boost.owner = get_tree().edited_scene_root

func clear_boosts() -> void:
	if !is_node_ready():
		await ready
	#boosts = get_tree().edited_scene_root.get_node("Boosts")
	boosts = get_node("Boosts")
	var boost_list: Array[Node] = boosts.get_children()
	for i in boost_list:
		i.queue_free()

func align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y.normalized()
	#xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func spawn_wall(spawn_xform: Transform3D):
	var new_obstacle: Node3D = obstacle_scene.instantiate()
	get_node("Obstacles").add_child(new_obstacle)
	new_obstacle.global_transform = spawn_xform

func _on_boost_picked_up(xform: Transform3D):
	await get_tree().create_timer(obst_spwn_delay).timeout
	spawn_wall(xform)
