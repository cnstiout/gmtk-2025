extends Node

@onready var road: Path3D = $Road
@onready var boost_pickup_scene = preload("uid://h2pheoljb6ha")

var nb_boost: int = 4
var boost_offset: float =  10.0


func _ready() -> void:
	for i in nb_boost:
		var boost_position = road.curve.sample_baked(boost_offset * i)
		var new_boost = boost_pickup_scene.instantiate()
		new_boost.position = boost_position
		get_tree().root.add_child.call_deferred(new_boost)
