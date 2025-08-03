extends Control

@onready var music_v_slider: VSlider = %MusicVSlider
@onready var sfxv_slider: VSlider = %SFXVSlider

func _ready() -> void:
	music_v_slider.value_changed.connect(set_music_level)
	sfxv_slider.value_changed.connect(set_sfx_level)
	update_sliders()

func update_sliders() -> void:
	music_v_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
	sfxv_slider.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX"))


func set_music_level(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)

func set_sfx_level(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
