extends Control

@onready var panel_upgrade: Panel = $Panel_Upgrade
@onready var panel_credit: Panel = $Panel_Credit
@onready var panel_settings: Panel = $Panel_Settings
@onready var slider_bgm: HSlider = $Panel_Settings/VBoxContainer/ColorRect/HSlider
@onready var panel_encyclopedia: Panel = $Panel_Encyclopedia
@onready var button_tower: Button = $Panel_Encyclopedia/HBoxContainer/Button_Tower
@onready var button_enemies: Button = $Panel_Encyclopedia/HBoxContainer/Button_Enemies
@onready var panel_tower: Panel = $Panel_Encyclopedia/Panel_Tower
@onready var panel_enemies: Panel = $Panel_Encyclopedia/Panel_Enemies
@onready var container: HBoxContainer = $Panel_Encyclopedia/HBoxContainer
@onready var panel_htp: Panel = $Panel_HTP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider_bgm.value = MusicPlayer.volume
	MusicPlayer.connect("volume_changed", Callable(self, "_on_volume_changed"))
	GameManager.reset_game()
	GameSpeedManager.reset_speed()


func _on_button_upgrade_pressed() -> void:
	panel_upgrade.visible = true


func _on_close_upgrade_pressed() -> void:
	panel_upgrade.visible = false
	panel_credit.visible = false
	panel_settings.visible = false
	panel_encyclopedia.visible = false
	panel_htp.visible = false

func _on_button_credit_pressed() -> void:
	panel_credit.visible = true


func _on_button_start_pressed() -> void:
	GameSpeedManager.set_game_speed(1.0)
	get_tree().change_scene_to_file("res://scene/select_level.tscn")


func _on_button_setting_pressed() -> void:
	panel_settings.visible = true
	
func _on_slider_bgm_value_changed(value: float) -> void:
	MusicPlayer.set_bgm_volume(value)
	
func _on_volume_changed(value):
	# update slider jika diperlukan
	if slider_bgm.value != value:
		slider_bgm.value = value

func _on_button_encyclopedia_pressed() -> void:
	panel_encyclopedia.visible = true
	container.visible = true
	panel_tower.visible = false
	panel_enemies.visible = false

func _on_button_tower_pressed() -> void:
	panel_tower.visible = true
	container.visible = false

func _on_button_enemies_pressed() -> void:
	panel_enemies.visible = true
	container.visible = false

func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_htp_pressed() -> void:
	panel_htp.visible = true
