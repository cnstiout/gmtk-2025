extends Control

@onready var main_menu_path = "uid://clt13pddeirxi"

@onready var replay_button: TextureButton = %ReplayButton
@onready var quit_button: TextureButton = %QuitButton
@onready var score_value_label: Label = %ScoreValueLabel
@onready var highscore_value_label: Label = %HighscoreValueLabel

func _ready() -> void:
	Events.new_run_score.connect(change_score)
	visibility_changed.connect(_on_visibility_changed)
	
	replay_button.pressed.connect(_on_button_replay_pressed)
	quit_button.pressed.connect(_on_button_quit_pressed)

func change_score(score: int) -> void:
	score_value_label.text = str(score)

func change_highscore(score: int) -> void:
	highscore_value_label.text = str(score)

func _on_visibility_changed() -> void:
	if visible:
		replay_button.grab_focus()

func reset() -> void:
	change_score(0)
	self.hide()

func _on_button_replay_pressed() -> void:
	Events.restart_current_level.emit()

func _on_button_quit_pressed() -> void:
	Events.request_main_menu.emit()
