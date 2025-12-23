extends Control

@onready var panel_settings: Panel = $Panel_Settings
@onready var slider_bgm: HSlider = $Panel_Settings/VBoxContainer/ColorRect/HSlider
@onready var panel_upgrade: Panel = $Panel_Upgrade

@onready var total_stars_label: Label = $Panel_Upgrade/total_stars

@onready var locked_level_panel: Panel = $Panel_Locked
@onready var ok_button: Button = $Panel_Locked/Button_Oke
@onready var message_label: Label = $Panel_Locked/message_label

@onready var flow_container_trap: FlowContainer = $Panel_Upgrade/FlowContainer_Trap
@onready var flow_container_tower: FlowContainer = $Panel_Upgrade/FlowContainer_Tower


@onready var button_chilli_bomb: Button = $Panel_Upgrade/button_trap_store/Button_Chilli_Bomb
@onready var chilli_bomb_count_label: Label = $Panel_Upgrade/FlowContainer_Trap/ColorRect/CountLabel
@onready var button_net_trap: Button = $Panel_Upgrade/button_trap_store/Button_Net_Trap
@onready var net_trap_count_label: Label = $Panel_Upgrade/FlowContainer_Trap/ColorRect2/CountLabel
@onready var button_gelatin_trap: Button = $Panel_Upgrade/button_trap_store/Button_Gelatin_Trap
@onready var gelatin_trap_count_label: Label = $Panel_Upgrade/FlowContainer_Trap/ColorRect3/CountLabel

@onready var panel_encyclopedia: Panel = $Panel_Encyclopedia
@onready var button_enemies: Button = $Panel_Encyclopedia/HBoxContainer/Button_Enemies


var gelatin_trap_price = 0
var net_trap_price = 0
var chilli_bomb_price = 0

var tower_prices = {
	"Garlic_Barrier": 3,    # 10 stars
	"Pepper_Grinder": 5,    # 15 stars
	"Ice_Chiller": 8        # 20 stars
}

var level_requirements = {
	"Garlic_Barrier": 2,  # Level 2
	"Pepper_Grinder": 3,  # Level 3  
	"Ice_Chiller": 4      # Level 4
}

func _ready() -> void:
	slider_bgm.value = MusicPlayer.volume
	MusicPlayer.connect("volume_changed", Callable(self, "_on_volume_changed"))

	locked_level_panel.visible = false
	panel_upgrade.visible = false
	GameManager.reset_game()
	GameSpeedManager.reset_speed()
	_update_level_buttons()
	_update_total_stars_display()
	_update_store_buttons()
	_update_chilli_bomb_display()
	_update_net_trap_display()
	_update_gelatin_trap_display()
	
	if GameManager.should_open_store:
		GameManager.should_open_store = false  # Reset
		call_deferred("_open_store_panel")
	

func _update_level_buttons():
	var level_buttons = [
		{"button": $Button_level1, "lock": null, "star_label": $Button_level1/stars_label_1},
		{"button": $Button_level2, "lock": $Button_level2/lock_2, "star_label": $Button_level2/stars_label_2},
		{"button": $Button_level3, "lock": $Button_level3/lock_3, "star_label": $Button_level3/stars_label_3},
		{"button": $Button_level4, "lock": $Button_level4/lock_4, "star_label": $Button_level4/stars_label_4},
		{"button": $Button_level5, "lock": $Button_level5/lock_5, "star_label": $Button_level5/stars_label_5}
	]
	
	for i in range(level_buttons.size()):
		var level = i + 1
		var button = level_buttons[i]["button"]
		var lock = level_buttons[i]["lock"]
		var star_label = level_buttons[i]["star_label"] as Label
		
		if button:
			var is_accessible = SaveManager.is_level_accessible(level)
			var is_completed = SaveManager.is_level_completed(level)
			var stars_count = SaveManager.get_level_stars(level)
			
			button.disabled = not is_accessible
			
			if lock:
				lock.visible = not is_accessible
			
			# Update star label
			if star_label:
				if stars_count > 0:
					star_label.visible = true
					# Tampilkan stars sebagai text: ⭐⭐⭐
					star_label.text = "⭐".repeat(stars_count)
					
					star_label.add_theme_font_size_override("font_size", 84)  # Ukuran font 24px
					
					# GESER POSISI (adjust sesuai kebutuhan)
					# Contoh: Posisi di atas button, center horizontal
					var button_size = button.size
					var label_width = star_label.size.x
					
					# Center horizontal di atas button
					star_label.position.x = (button_size.x - label_width) / 2
					star_label.position.y = 200
				else:
					star_label.visible = false

func _on_buy_ice_pressed():
	_buy_tower("Ice_Chiller", 8)

func _on_buy_garlic_pressed():
	_buy_tower("Garlic_Barrier", 3)

func _on_buy_pepper_pressed():
	_buy_tower("Pepper_Grinder", 5)

func _on_buy_chilli_bomb_pressed():
	var total_stars = SaveManager.get_total_stars()
	
	# Cek cukup stars
	if total_stars >= chilli_bomb_price:
		# Kurangi stars
		SaveManager.save_data["total_stars"] -= chilli_bomb_price
		
		# Tambahkan chilli bomb
		SaveManager.add_consumable("chilli_bomb", 1)
		
		SaveManager.save_game()
		
		print("✅ Purchased Chilli Bomb for " + str(chilli_bomb_price) + " stars")
		_update_total_stars_display()
		_update_chilli_bomb_display()
	else:
		print("❌ Not enough stars! Need: " + str(chilli_bomb_price) + ", Have: " + str(total_stars))

func _on_buy_net_trap_pressed():
	var total_stars = SaveManager.get_total_stars()
	
	# Cek cukup stars
	if total_stars >= net_trap_price:
		# Kurangi stars
		SaveManager.save_data["total_stars"] -= net_trap_price
		
		# Tambahkan net trap ke inventory
		SaveManager.add_consumable("net_trap", 1)
		
		SaveManager.save_game()
		
		print("✅ Purchased Net Trap for " + str(net_trap_price) + " stars")
		_update_total_stars_display()
		_update_net_trap_display()

func _on_buy_gelatin_trap_pressed():
	var total_stars = SaveManager.get_total_stars()
	
	# Cek cukup stars
	if total_stars >= gelatin_trap_price:
		# Kurangi stars
		SaveManager.save_data["total_stars"] -= gelatin_trap_price
		
		# Tambahkan gelatin trap ke inventory
		SaveManager.add_consumable("gelatin_bounce", 1)
		
		SaveManager.save_game()
		
		print("✅ Purchased Gelatin Bounce Trap for " + str(gelatin_trap_price) + " stars")
		_update_total_stars_display()
		_update_gelatin_trap_display()
	else:
		print("❌ Not enough stars! Need: " + str(gelatin_trap_price) + ", Have: " + str(total_stars))

# Update display gelatin trap
func _update_gelatin_trap_display():
	if gelatin_trap_count_label:
		var count = SaveManager.get_consumable_amount("gelatin_bounce")
		gelatin_trap_count_label.text = "Owned: " + str(count)
		print("🪩 Gelatin traps owned: " + str(count))
	
	# Update button state
	if button_gelatin_trap:
		var total_stars = SaveManager.get_total_stars()
		
		if total_stars < gelatin_trap_price:
			button_gelatin_trap.text = "💰 " + str(gelatin_trap_price) + " ⭐"
			button_gelatin_trap.disabled = true
			button_gelatin_trap.tooltip_text = "Need " + str(gelatin_trap_price) + " stars\nYou have: " + str(total_stars)
		else:
			button_gelatin_trap.text = "BUY - " + str(gelatin_trap_price) + " ⭐"
			button_gelatin_trap.disabled = false
			button_gelatin_trap.tooltip_text = "Click to buy for " + str(gelatin_trap_price) + " stars"
			
func _update_net_trap_display():
	if net_trap_count_label:
		var count = SaveManager.get_consumable_amount("net_trap")
		net_trap_count_label.text = "Owned: " + str(count)
	
	# Update button state
	if button_net_trap:
		var total_stars = SaveManager.get_total_stars()
		
		if total_stars < net_trap_price:
			button_net_trap.text = "💰 " + str(net_trap_price) + " ⭐"
			button_net_trap.disabled = true
			button_net_trap.tooltip_text = "Need " + str(net_trap_price) + " stars\nYou have: " + str(total_stars)
		else:
			button_net_trap.text = "BUY - " + str(net_trap_price) + " ⭐"
			button_net_trap.disabled = false
			button_net_trap.tooltip_text = "Click to buy for " + str(net_trap_price) + " stars"
# Update display chilli bomb
func _update_chilli_bomb_display():
	if chilli_bomb_count_label:
		var count = SaveManager.get_consumable_amount("chilli_bomb")
		chilli_bomb_count_label.text = "Owned: " + str(count)
	
	# Update button state
	if button_chilli_bomb:
		var total_stars = SaveManager.get_total_stars()
		
		if total_stars < chilli_bomb_price:
			button_chilli_bomb.text = "💰 " + str(chilli_bomb_price) + " ⭐"
			button_chilli_bomb.disabled = true
			button_chilli_bomb.tooltip_text = "Need " + str(chilli_bomb_price) + " stars\nYou have: " + str(total_stars)
		else:
			button_chilli_bomb.text = "BUY - " + str(chilli_bomb_price) + " ⭐"
			button_chilli_bomb.disabled = false
			button_chilli_bomb.tooltip_text = "Click to buy for " + str(chilli_bomb_price) + " stars"
			
func _buy_tower(tower_type: String, price: int):
	var total_stars = SaveManager.save_data["total_stars"]
	
	# Cek sudah punya
	if SaveManager.has_tower(tower_type):
		print("Already own " + tower_type)
		return
	
	# Cek cukup stars
	if total_stars >= price:
		if SaveManager.buy_tower(tower_type):
			# Kurangi stars
			SaveManager.save_data["total_stars"] -= price
			SaveManager.save_game()
			
			print("✅ Purchased " + tower_type + " for " + str(price) + " stars")
			_update_store_buttons()
			_update_total_stars_display()
		else:
			print("❌ Failed to buy " + tower_type)
	else:
		print("❌ Not enough stars! Need: " + str(price) + ", Have: " + str(total_stars))

func _update_store_buttons():
	var highest_level = SaveManager.save_data["highest_level"]
	var total_stars = SaveManager.save_data["total_stars"]
	
	# Update setiap button
	_update_button_state("Garlic_Barrier", highest_level, total_stars)
	_update_button_state("Pepper_Grinder", highest_level, total_stars)
	_update_button_state("Ice_Chiller", highest_level, total_stars)

func _update_button_state(tower_type: String, highest_level: int, total_stars: int):
	var required_level = level_requirements.get(tower_type, 1)
	var price = tower_prices.get(tower_type, 0)
	var has_tower = SaveManager.has_tower(tower_type)
	
	# Cari button berdasarkan nama
	var button = null
	match tower_type:
		"Garlic_Barrier":
			button = $Panel_Upgrade/button_tower_store.get_node_or_null("Button_Garlic")
		"Pepper_Grinder":
			button = $Panel_Upgrade/button_tower_store.get_node_or_null("Button_Pepper")
		"Ice_Chiller":
			button = $Panel_Upgrade/button_tower_store.get_node_or_null("Button_Ice")
	
	if not button:
		return
	
	# Update button berdasarkan kondisi
	if has_tower:
		# Sudah dibeli
		button.text = "✅ OWNED"
		button.disabled = true
	elif highest_level < required_level:
		# Belum unlock level
		button.text = "🔒 Level " + str(required_level)
		button.disabled = true
		button.tooltip_text = "Complete Level " + str(required_level - 1) + " to unlock"
	elif total_stars < price:
		# Level sudah unlock tapi stars kurang
		button.text = "💰 " + str(price) + " ⭐"
		button.disabled = true
		button.tooltip_text = "Need " + str(price) + " stars\nYou have: " + str(total_stars)
	else:
		# Bisa dibeli
		button.text = "BUY - " + str(price) + " ⭐"
		button.disabled = false
		button.tooltip_text = "Click to buy for " + str(price) + " stars"
		
func _update_total_stars_display():
	if total_stars_label:
		var total_stars = SaveManager.get_total_stars()
		total_stars_label.text = str(total_stars)
	_update_chilli_bomb_display()
	_update_net_trap_display()
	_update_gelatin_trap_display()

func _open_store_panel():
	# Pastikan scene sudah siap
	await get_tree().process_frame
	
	# Buka panel store
	$Panel_Upgrade.visible = true
	
func _on_button_setting_pressed() -> void:
	panel_settings.visible = true

func _on_close_settings_pressed() -> void:
	panel_settings.visible = false
	panel_upgrade.visible = false

func _on_button_level_1_pressed() -> void:
	_start_level(1, "res://scene/Main.tscn")

func _on_button_level_2_pressed() -> void:
	_start_level(2, "res://scene/main_level2.tscn")

func _on_button_level_3_pressed() -> void:
	_start_level(3, "res://scene/main_level3.tscn")

func _on_button_level_4_pressed() -> void:
	_start_level(4, "res://scene/main_level4.tscn")
	
func _on_button_level_5_pressed() -> void:
	_start_level(5, "res://scene/main_level5.tscn")

func _start_level(level: int, scene_path: String):
	if SaveManager.is_level_accessible(level):
		GameSpeedManager.set_game_speed(1.0)
		GameManager.set_level(level)
		get_tree().change_scene_to_file(scene_path)
	else:
		print("🔒 Level ", level, " locked!")
		_show_locked_panel(level)

func _show_locked_panel(level: int):
	# Tampilkan panel terkunci
	locked_level_panel.visible = true
	
	if message_label:
		message_label.text = "Level " + str(level) + " terkunci!\nSelesaikan level " + str(level-1) + " terlebih dahulu."
func _on_ok_button_pressed() -> void:
	locked_level_panel.visible = false

func _on_button_reset_pressed() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Reset Progress"
	dialog.dialog_text = "Yakin ingin menghapus semua progress?\nSemua level yang terbuka akan dikunci kembali."
	dialog.confirmed.connect(_confirm_reset)
	
	add_child(dialog)
	dialog.popup_centered()

func _confirm_reset():
	SaveManager.reset_progress()
	_update_level_buttons()
	_update_total_stars_display()
	print("🔄 All progress reset")
	
func _on_slider_bgm_value_changed(value: float) -> void:
	MusicPlayer.set_bgm_volume(value)
	
func _on_volume_changed(value):
	# update slider jika diperlukan
	if slider_bgm.value != value:
		slider_bgm.value = value

func _on_button_upgrade_pressed() -> void:
	panel_upgrade.visible = true

	
func _on_button_select_tower_pressed() -> void:
	flow_container_tower.visible = true
	flow_container_trap.visible = false
	$Panel_Upgrade/button_trap_store.visible = false
	$Panel_Upgrade/button_tower_store.visible = true
func _on_button_select_trap_pressed() -> void:
	flow_container_trap.visible = true
	flow_container_tower.visible = false
	$Panel_Upgrade/button_trap_store.visible = true
	$Panel_Upgrade/button_tower_store.visible = false
	
func _on_button_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")
	
func _on_quit_game_pressed() -> void:
	get_tree().quit()

func _on_button_encyclopedia_pressed() -> void:
	panel_encyclopedia.visible = !panel_encyclopedia.visible
	call_deferred("set_initial_focus")
func set_initial_focus():
	button_enemies.grab_focus()
	
