class_name Player
extends CharacterBody3D

@onready var model: Node3D = $Model

@onready var engine_audio_player: AudioStreamPlayer = $EngineAudioPlayer
@onready var engine_start_sfx: AudioStreamPlayer = $EngineStartSFX
@onready var hurt_audio_player: AudioStreamPlayer = $HurtAudioPlayer
@onready var explosion_sfx: AudioStreamPlayer = $ExplosionSFX
@onready var bank_sfx: AudioStreamPlayer = $BankSFX
@onready var trap_sfx: AudioStreamPlayer = $TrapSFX
@onready var sonic_boom_sfx: AudioStreamPlayer = $SonicBoomSFX

@onready var boost_audio_player: AudioStreamPlayer = $BoostAudioPlayer

@export var road: Road:
	set(value):
		road = value
		lane_offset = road.lane_width

var change_lane_speed: float = 0.1
var bank_angle_d: float = 30.0
var bank_anim_time: float = 0.1
var bank_anim_rectify_time: float = 0.2

var current_lane: int = 0
var lane_offset: float
var in_movement: bool = false

var can_move = false

func _ready() -> void:
	Events.trap_triggered.connect(trap_fx)
	Events.boost_picked_up.connect(_boost_effect)
	
	if road:
		lane_offset = road.lane_width

func start_engine_rev() -> void:
	engine_start_sfx.play()

func remove_brakes() -> void:
	engine_start_sfx.stop()
	sonic_boom_sfx.play()
	engine_audio_player.play()

func _process(_delta: float) -> void:
	if can_move:
		if Input.is_action_just_pressed("player_left"):
			change_lane(current_lane - 1)
			
		elif Input.is_action_just_pressed("player_right"):
			change_lane(current_lane + 1)

# Move the player to the specified lane (The middle lane being 0, the most left one being -n and the most right one n)
func change_lane(lane: int) -> void:
	if lane == current_lane || in_movement:
		return
	var move: int = lane - current_lane
	if road._is_valid_lane(lane):
		if move < 0:
			_bank(-1)
		else:
			_bank(1)
		var tween = get_tree().create_tween()
		in_movement = true
		tween.tween_property(self, "position", Vector3(position.x + (lane_offset * move), position.y, position.z), change_lane_speed)
		await tween.finished
		in_movement = false
		current_lane = lane

func reset() -> void:
	current_lane = 0
	position.x = 0

func _boost_effect(_boost_xform: Transform3D) -> void:
	boost_audio_player.play()

func _bank(direction: int) -> void:
	bank_sfx.play()
	var tween = get_tree().create_tween()
	tween.tween_property(model,
		"rotation:z",
		model.rotation.z + deg_to_rad(bank_angle_d) * direction,
		bank_anim_time)
	
	tween.tween_property(model,
		"rotation:z", 
		0,
		bank_anim_rectify_time)

func hurt_fx() -> void:
	hurt_audio_player.play()

func die_fx() -> void:
	explosion_sfx.play()

func trap_fx(_trap_xform: Transform3D) -> void:
	trap_sfx.play()
