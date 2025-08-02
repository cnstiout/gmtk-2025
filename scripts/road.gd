class_name Road
extends Path3D

@onready var boost_pickup_scene = preload("uid://h2pheoljb6ha")
@onready var trap_item_scene = preload("uid://c64q8c8m5bhub")
@onready var obstacle_scene = preload("uid://xqn5l3daobv1")

@onready var road_polygon: CSGPolygon3D = $RoadCSGPolygon3D
@onready var boosts: Node = %Boosts
@onready var traps: Node = %Traps
@onready var obstacles: Node = %Obstacles
@onready var radar_placement: PathFollow3D = $RadarPlacement
@onready var item_spawner_path: PathFollow3D = %ItemSpawnerPath

@export_range(3, 13, 2) var nb_lane: int = 3:
	set(value):
		nb_lane = value
		generate_track()

@export var lane_width: float = 1
@export var road_thickness: float = 0.1
@export var item_vertical_road_offset: float = 0.2
@export var boosts_road_offset: float = 0.2
var road_length: float

@export var radar_offset: float = 3.0

@export var min_nb_traps: int = 5
@export var min_nb_boost: int = 5
@export var no_item_placement_radar: float = 5.0
@export var item_placement_interval: float = 15.0
@export var item_placement_offset: float = 3.0
var nb_spawn_location: int

var obst_spwn_delay: float = 1.0

var spawned_items: Array[Node3D]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	Events.boost_picked_up.connect(_on_boost_picked_up)
	Events.trap_triggered.connect(_on_trap_triggered)
	
	road_length = curve.get_baked_length()
	nb_spawn_location = floor((road_length - (radar_offset * 2)) / item_placement_interval)
	radar_placement.progress = radar_offset

	setup_items()

func reset() -> void:
	remove_obstacles()
	setup_items()

func remove_obstacles() -> void:
	for i in obstacles.get_children():
		i.queue_free()

# Generate the road polygon that is swept along the path
func generate_track() -> void:
	if road_polygon:
		var track_polygon: PackedVector2Array
		track_polygon.append(Vector2(-(lane_width * nb_lane) / 2, 0.0))
		track_polygon.append(Vector2((lane_width * nb_lane) / 2, 0.0))
		track_polygon.append(Vector2((lane_width * nb_lane) / 2, -road_thickness))
		track_polygon.append(Vector2(-(lane_width * nb_lane) / 2, -road_thickness))
		road_polygon.polygon = track_polygon

func setup_items() -> void:
	clear_all_items()
	
	item_spawner_path.progress = 0 + radar_offset + no_item_placement_radar
	
	var item_list: Array[Constants.ItemType] = _get_item_list_array()
	for i in item_list:
		spawn_item(i)
	
	#for i in min_nb_traps:
		#spawn_item(Constants.ItemType.BOOST)
	#
	#for i in min_nb_traps:
		#spawn_item(Constants.ItemType.TRAP)

func spawn_item(type: Constants.ItemType) -> void:
	if !is_node_ready():
		await ready
	
	item_spawner_path.progress += item_placement_interval
	
	if type != Constants.ItemType.EMPTY:
		
		var rand_lane: int = randi_range(0, nb_lane - 1) - (nb_lane / floor(2))
		#var track_position: float = randf() * curve.get_baked_length()
		
		
		# Used to remove the offset used on the progress to add variation
		var spawn_location: float = item_spawner_path.progress
		item_spawner_path.progress += randf_range(-item_placement_offset, item_placement_offset)
		var new_transform = item_spawner_path.transform
		item_spawner_path.progress = spawn_location
		#var new_transform = curve.sample_baked_with_rotation(track_position, false, true)
		new_transform = new_transform.translated(new_transform.basis.y * item_vertical_road_offset)
		new_transform = new_transform.translated(new_transform.basis.x * (rand_lane * lane_width))
		
		
		var new_item: Node3D
		match type:
			Constants.ItemType.BOOST:
				new_item = boost_pickup_scene.instantiate()
				boosts.add_child(new_item)
			Constants.ItemType.TRAP:
				new_item = trap_item_scene.instantiate()
				traps.add_child(new_item)
		
		if !new_item.is_inside_tree():
			await new_item.tree_entered
		new_item.global_transform = global_transform * new_transform
		spawned_items.append(new_item)

func clear_all_items() -> void:
	if !is_node_ready():
		await ready
	
	# Remove all boosts
	boosts = get_node("Boosts")
	var boost_list: Array[Node] = boosts.get_children()
	for i in boost_list:
		spawned_items.erase(i)
		i.queue_free()
	
	# Remove all traps
	traps = get_node("Traps")
	var trap_list: Array[Node] = traps.get_children()
	for i in trap_list:
		spawned_items.erase(i)
		i.queue_free()

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

func _get_item_list_array() -> Array[Constants.ItemType]:
	var item_array: Array[Constants.ItemType]
	
	for i in min_nb_boost:
		item_array.append(Constants.ItemType.BOOST)
	for i in min_nb_traps:
		item_array.append(Constants.ItemType.TRAP)
	for i in ((nb_spawn_location - min_nb_boost) - min_nb_traps):
		item_array.append(randi_range(0, Constants.ItemType.size() - 1))
	
	randomize()
	item_array.shuffle()
	
	return item_array

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

func _on_boost_picked_up(_xform: Transform3D):
	pass

# Check if the parameter lane is a valid lane
func _is_valid_lane(lane: int) -> bool:
	var valid: bool = true
	var lane_offseted = lane + (nb_lane / floor(2))
	if lane_offseted < 0 || lane_offseted >= nb_lane:
		valid = false
	return valid

func _on_trap_triggered(trap_xform: Transform3D) -> void:
	await get_tree().create_timer(obst_spwn_delay).timeout
	spawn_wall(trap_xform)
