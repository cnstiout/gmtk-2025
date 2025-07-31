extends Node3D

@export var road: Road
@export var countdown_time: int = 3


@onready var player_track_scene = preload("uid://blwdspsggj7au")
@onready var countdown_timer: Timer = %CountdownTimer
@onready var countdown_label: Label = $HUD/CountdownLabel
@onready var gameover_screen: Control = %GameoverScreen
@onready var speed_label: Label = %SpeedLabel
@onready var score_label: Label = %ScoreLabel

var player_track: PlayerTrack

var high_score: int = 0:
	set(value):
		high_score = value

func _ready() -> void:
	Events.radar_triggered.connect(_on_radar_triggered)
	Events.player_died.connect(_on_player_died)
	player_track = player_track_scene.instantiate()
	player_track.road = road
	player_track.speed_label = speed_label
	road.add_child(player_track)
	
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	countdown_timer.start()

func start_run() -> void:
	countdown_label.hide()
	countdown_timer.stop()
	player_track.start()

func decrease_countdown() -> void:
	if countdown_time > 1:
		countdown_time -= 1
		countdown_label.text = str(countdown_time)
	else:
		start_run()

func _on_player_died() -> void:
	player_track.stop()
	show_gameover()

func show_gameover() -> void:
	gameover_screen.show()

func _on_countdown_timer_timeout() -> void:
	decrease_countdown()

func _on_radar_triggered() -> void:
	road.setup_items()
	update_high_score(player_track.get_converted_speed())

func update_high_score(new_score: int) -> void:
	#if new_score > high_score:
		#high_score = new_score
		#score_label.text = str(new_score)
	pass
