extends Node

@onready var bgm: AudioStreamPlayer2D = $AudioStreamPlayer2D

var volume: float = 0.5   # nilai global
signal volume_changed(value)

func set_bgm_volume(value: float):
	# Simpan nilai volume
	volume = clamp(value, 0.0, 1.0)

	# Ubah BGM
	bgm.volume_db = linear_to_db(volume)
	
	SaveManager.save_data["settings"]["music_volume"] = volume
	SaveManager.save_game()

func load_volume_settings():
	# Load volume dari save data
	if SaveManager.save_data.has("settings") and SaveManager.save_data["settings"].has("music_volume"):
		volume = SaveManager.save_data["settings"]["music_volume"]
	else:
		# Default value
		volume = 0.5
	
	# Terapkan volume
	bgm.volume_db = linear_to_db(volume)
	# Beritahu semua slider lain
	emit_signal("volume_changed", volume)
