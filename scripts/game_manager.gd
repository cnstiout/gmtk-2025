extends Node

@onready var road: Road = $Road

func _ready() -> void:
	pass
	#for i in nb_boost:
		#spawn_random_boost()
		#road.curve.get_baked_points()
		#var boost_position = road.curve.sample_baked(boost_offset * i)
		#var new_boost = boost_pickup_scene.instantiate()
		#new_boost.position = boost_position
		#get_tree().root.add_child.call_deferred(new_boost)
