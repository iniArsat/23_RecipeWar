extends Node

@onready var coin_label = $CanvasLayer/UI_Management/coin_lbl
#@onready var score: Label = $CanvasLayer/UI_Management/Victory_Panel/Score
@onready var health_label: Label = $CanvasLayer/UI_Management/health_lbl
@onready var wave_manager = $WaveManager
@onready var countdown_label: Label =$CanvasLayer/UI_Management/Countdown
@onready var circular_progress: TextureProgressBar = $CanvasLayer/UI_Management/CircleProgressBar
@onready var circular_progress2: TextureProgressBar = $CanvasLayer/UI_Management/CircleProgressBar2
@onready var ui_upgrade: Panel = $CanvasLayer/UI_Management/Ui_Upgrade
@onready var speed_button: TextureButton = $CanvasLayer/UI_Management/Percepat
@onready var gameover_panel: Panel = $CanvasLayer/UI_Management/Gameover_Panel
@onready var victory_panel: Panel = $CanvasLayer/UI_Management/Victory_Panel
@onready var score_result: Label = $CanvasLayer/UI_Management/Victory_Panel/Score
@onready var wave_lbl: Label = $CanvasLayer/UI_Management/wave_lbl
@onready var pause_panel: Panel = $CanvasLayer/UI_Management/Paused_Panel
@onready var instruction_panel: Panel = $CanvasLayer/UI_Management/Instruction_Panel
@onready var base_sprite: Sprite2D = $Base
@onready var start_wave_button: Button = $CanvasLayer/UI_Management/Start_Wave
@onready var start_wave_button2: Button = $CanvasLayer/UI_Management/Start_Wave2
@onready var tower_name_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell/Tower_Name_Label
@onready var tower_name_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Tower_Name_Label
@onready var tower_name_label3: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell2/Tower_Name_Label
@onready var tower_name_label4: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Tower_Name_Label
@onready var upgrade_cost_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Upgrade_Cost_Label
@onready var upgrade_cost_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Upgrade_Cost_Label
@onready var label_ket: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Label_Ket
@onready var label_ket2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Label_Ket


@onready var upgrade_button: Button = $CanvasLayer/UI_Management/Ui_Upgrade/Upgrade_Button
@onready var close_upgrade: Button = $CanvasLayer/UI_Management/Ui_Upgrade/Close_Upgrade
@onready var sell_button: Button = $CanvasLayer/UI_Management/Ui_Upgrade/Sell_Button
@onready var sell_price_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell/Sell_Value
@onready var sell_price_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell2/Sell_Value
@onready var Trap_Placement: Node2D = $Trap_Placement

@onready var sell_info: Panel = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell2
@onready var upgrade_info: Panel = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2
@onready var panel_sell_2: Panel = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Sell
@onready var panel_upgrade_2: Panel = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade
var is_tower_on_left_side: bool = false

# NEW: Variabel sederhana untuk tutorial Level 1
@onready var tutorial_startwave: Sprite2D = $CanvasLayer/UI_Management/PopUp_StartWave
@onready var tutorial_drag_tower: Sprite2D = $CanvasLayer/UI_Management/PopUp_Drag
@onready var tutorial_upgrade: Sprite2D = $CanvasLayer/UI_Management/PopUp_Upgrade
@onready var tutorial_input_blocker: Panel = $CanvasLayer/UI_Management/Panel_block_step1
@onready var tutorial_input_blocker_2: Panel = $CanvasLayer/UI_Management/Panel_block_step2


@onready var panel_settings: Panel = $CanvasLayer/UI_Management/Paused_Panel/Panel_Settings
@onready var slider_music: HSlider = $CanvasLayer/UI_Management/Paused_Panel/Panel_Settings/VBoxContainer/ColorRect/HSlider

var tutorial_wave_completed := false
var first_wave_finished := false


# Variabel untuk reward system
@export var max_countdown_time := 30.0
@export var max_reward := 50
var current_countdown_timer := 0.0
var is_countdown_active := false
var wave_reward := 0
var has_started_first_wave := false

var game_started = false

@onready var star_1_blank: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_1_blank
@onready var star_1_fill: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_1_fill
@onready var star_2_blank: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_2_blank
@onready var star_2_fill: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_2_fill
@onready var star_3_blank: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_3_blank
@onready var star_3_fill: Sprite2D = $CanvasLayer/UI_Management/Victory_Panel/star_3_fill

@onready var current_damage_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Before_Container/DMG_Before
@onready var current_range_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Before_Container/RNG_Before
@onready var current_cooldown_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/Before_Container/CD_Before
@onready var next_damage_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/After_Container/DMG_After
@onready var next_range_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/After_Container/RNG_After
@onready var next_cooldown_label: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade/After_Container/CD_After
@onready var current_damage_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Before_Container/DMG_Before
@onready var current_range_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Before_Container/RNG_Before
@onready var current_cooldown_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/Before_Container/CD_Before
@onready var next_damage_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/After_Container/DMG_After
@onready var next_range_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/After_Container/RNG_After
@onready var next_cooldown_label2: Label = $CanvasLayer/UI_Management/Ui_Upgrade/Panel_Upgrade2/After_Container/CD_After
@onready var tower_panel_2: Panel = $CanvasLayer/UI_Management/Panel_Tower/HBoxContainer/TowerPanel2
@onready var tower_panel_1: Panel = $CanvasLayer/UI_Management/Panel_Tower/HBoxContainer/TowerPanel
@onready var pathway_sprite: Sprite2D = $CanvasLayer/UI_Management/Pathway_Sprite

@export var chilli_bomb_panel_scene: PackedScene
@export var net_trap_panel_scene: PackedScene

@onready var trap_container: HBoxContainer = $CanvasLayer/UI_Management/Panel_Tower/HBoxContainer
@onready var chilli_bomb_panel_instance = null
@onready var net_trap_panel_instance = null


var tutorial_step := 0  # 0: belum mulai, 1: start wave, 2: drag tower, 3: upgrade, 4: selesai
var tutorial_completed_steps := {
	"start_wave": false,
	"drag_tower": false,
	"upgrade_tower": false
}

var current_tower = null

func _ready() -> void:
	GameSpeedManager.set_game_speed(0.0)
	instruction_panel.visible = true
	ui_upgrade.visible = false
	panel_settings.visible = false
	pause_panel.visible = false
	Trap_Placement.visible = true
	
	# NEW: Setup tutorial label (sembunyikan dulu)
	if tutorial_startwave:
		tutorial_startwave.visible = false
	if tutorial_drag_tower:
		tutorial_drag_tower.visible = false
	if tutorial_upgrade:
		tutorial_upgrade.visible = false
	if pathway_sprite:
		pathway_sprite.visible = false
		
	if slider_music:
		slider_music.value = MusicPlayer.volume
		MusicPlayer.connect("volume_changed", Callable(self, "_on_music_volume_changed"))
		
	instruction_panel.instruction_completed.connect(_on_instruction_completed)
	instruction_panel.skip_instructions.connect(_on_skip_instructions)
	
	if start_wave_button:
		start_wave_button.visible = false
		start_wave_button.pressed.connect(_on_start_wave_button_pressed)
	if start_wave_button2:
		start_wave_button2.visible = false
		start_wave_button2.pressed.connect(_on_start_wave_button_pressed)
	
		
	GameManager.update_coin.connect(_on_coins_changed)
	_on_coins_changed(GameManager.coin)
	GameManager.update_health.connect(_on_health_changed)
	_on_health_changed(GameManager.health_player)
	GameManager.invalid_drop_areas = get_tree().get_nodes_in_group("invalid_drop_area")
	GameManager.valid_drop_areas = get_tree().get_nodes_in_group("valid_drop_area")
	GameManager.valid_trap_areas = get_tree().get_nodes_in_group("valid_trap_area")
	GameManager.base_damaged.connect(flash_base_simple)
	
	GameSpeedManager.game_speed_changed.connect(_on_game_speed_changed)
	GameSpeedManager.game_paused.connect(_on_game_paused)
	GameManager.game_over.connect(_on_game_over)
	wave_manager.victory_achieved.connect(_on_victory_achieved)
	gameover_panel.visible = false
	GameSpeedManager.reset_speed()
	
	wave_manager.wave_countdown_started.connect(_on_wave_countdown_started)
	wave_manager.wave_countdown_updated.connect(_on_wave_countdown_updated)
	wave_manager.wave_countdown_finished.connect(_on_wave_countdown_finished)
	
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	
	wave_manager.wave_changed.connect(_on_wave_changed)
	wave_manager.all_enemies_defeated.connect(_start_next_wave_countdown)
	
	_check_purchased_towers()
	_load_chilli_bombs()
	_setup_tutorial_z_index()

func _process(delta: float) -> void:
	if is_countdown_active:
		current_countdown_timer += delta
		_update_start_wave_button_text()
	if GameManager.current_level == 1:
		if tutorial_step == 2 and not tutorial_completed_steps["drag_tower"]:
			check_tower_placed()
		#elif tutorial_step == 3 and not tutorial_completed_steps["upgrade_tower"]:
			#pass

func _load_chilli_bombs():
	var bomb_count = SaveManager.get_consumable_amount("chilli_bomb")
	var net_trap_count = SaveManager.get_consumable_amount("net_trap")
	
	print("💣 Chilli Bombs: " + str(bomb_count))
	print("🕸️ Net Traps: " + str(net_trap_count))
	
	if bomb_count > 0:
		_add_trap_to_ui("chilli_bomb")
	
	if net_trap_count > 0:
		_add_trap_to_ui("net_trap")

func _add_chilli_bomb_to_ui():
	if chilli_bomb_panel_scene:
		# Hapus yang lama jika ada
		if chilli_bomb_panel_instance:
			chilli_bomb_panel_instance.queue_free()
		
		# Buat instance baru
		chilli_bomb_panel_instance = chilli_bomb_panel_scene.instantiate()
		
		# Tambahkan ke container
		trap_container.add_child(chilli_bomb_panel_instance)
		print("✅ Chilli Bomb added to UI")

func _add_trap_to_ui(trap_type: String):
	# Tentukan scene berdasarkan trap type
	var trap_scene = null
	var trap_instance_name = ""
	
	match trap_type:
		"chilli_bomb":
			if chilli_bomb_panel_scene:
				trap_scene = chilli_bomb_panel_scene
				trap_instance_name = "chilli_bomb_panel"
				# Hapus yang lama jika ada
				if chilli_bomb_panel_instance:
					chilli_bomb_panel_instance.queue_free()
		"net_trap":
			if net_trap_panel_scene:
				trap_scene = net_trap_panel_scene
				trap_instance_name = "net_trap_panel"
				# Hapus yang lama jika ada
				if net_trap_panel_instance:
					net_trap_panel_instance.queue_free()
	if trap_scene and trap_container:
		# Buat instance baru
		var trap_instance = trap_scene.instantiate()
		trap_instance.name = trap_instance_name
		
		# Setup trap instance
		if trap_instance.has_method("set_trap_type"):
			match trap_type:
				"chilli_bomb":
					trap_instance.set_trap_type("Chili_Bomb_Trap")
				"net_trap":
					trap_instance.set_trap_type("Net_Trap")
		
		# Tambahkan ke container
		trap_container.add_child(trap_instance)
		
		# Simpan reference
		if trap_type == "chilli_bomb":
			chilli_bomb_panel_instance = trap_instance
		
		print("✅ " + trap_type + " added to UI")

#func _update_chilli_bomb_count():
	#if chilli_bomb_panel_instance:
		#var count = SaveManager.get_consumable_amount("chilli_bomb")
		#chilli_bomb_panel_instance.update_count(count)
#
#func _remove_chilli_bomb_from_ui():
	#if chilli_bomb_panel_instance:
		#chilli_bomb_panel_instance.queue_free()
		#chilli_bomb_panel_instance = null
		
func _check_purchased_towers():
	var locked_panels = {
		"Ice_Chiller": get_node_or_null("CanvasLayer/locked_Ice"),
		"Garlic_Barrier": get_node_or_null("CanvasLayer/locked_Garlic"),
		"Pepper_Grinder": get_node_or_null("CanvasLayer/locked_Pepper")
	}
	
	for tower_name in locked_panels:
		if SaveManager.has_tower(tower_name) and locked_panels[tower_name]:
			locked_panels[tower_name].visible = false
			print("✅ " + tower_name + " purchased - hiding locked panel")
		
func _on_coins_changed(new_amount: int) -> void:
	coin_label.text = "Coin : " + str(new_amount)
	coin_label.text = str(new_amount)

func _on_health_changed(new_health: int) -> void:
	health_label.text = str(new_health)

func _start_next_wave_countdown():
	
	if wave_manager.current_wave < wave_manager.waves.size():
		print("⏳ Memulai countdown untuk wave berikutnya...")
		_start_wave_countdown()
		
func _on_speed_button_pressed():
	GameManager.toggle_game_speed()

func _on_game_speed_changed(speed_multiplier: float):
	_update_speed_button_text()
	
	
func _on_instruction_completed():
	instruction_panel.visible = false
	_start_game()

func _on_skip_instructions():
	instruction_panel.visible = false
	_start_game()
	
func _start_game():
	# NEW: Cek apakah Level 1, jika ya tampilkan tutorial
	var current_level = GameManager.current_level
	
	if current_level == 1:
		# Mulai tutorial step 1
		_start_tutorial_step(1)
		if not has_started_first_wave:
			_start_wave_countdown()
	else:
		# Level lainnya langsung mulai
		GameSpeedManager.set_game_speed(1.0)
		if not has_started_first_wave:
			_start_wave_countdown()

func _setup_tutorial_z_index():
	# Set input blocker di layer terbawah (z-index rendah)
	if tutorial_input_blocker:
		tutorial_input_blocker.z_index = 0
		tutorial_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Set tutorial sprites di layer atas (z-index tinggi)
	if tutorial_startwave:
		tutorial_startwave.z_index = 10
	if tutorial_drag_tower:
		tutorial_drag_tower.z_index = 10
	if tutorial_upgrade:
		tutorial_upgrade.z_index = 10
		
func _start_tutorial_step(step: int):
	tutorial_step = step
	match step:
		1:
			# Tutorial step 1: Start Wave
			_show_level1_tutorial()
		2:
			# Tutorial step 2: Drag Tower
			_show_drag_tower_tutorial()
		3:
			# Tutorial step 3: Upgrade Tower (setelah wave pertama)
			if first_wave_finished:
				_show_upgrade_tutorial()
			else:
				print("⏳ Tunggu wave pertama selesai dulu...")
		4:
			# Tutorial selesai
			_complete_tutorial()

func _show_drag_tower_tutorial():
	print("📢 Tutorial Step 2: Drag and Place Tower")
	
	# Pause game
	GameSpeedManager.set_game_speed(0.0)
	_set_speed_button_enabled(false)
	_set_start_button_enabled(false)
	_set_tower_panel_popup_enabled(false)
	
	if tutorial_input_blocker:
		tutorial_input_blocker.visible = true
		tutorial_input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tutorial_input_blocker.z_index = 11
	
	# Tampilkan sprite tutorial drag tower DI ATAS
	if tutorial_drag_tower:
		tutorial_drag_tower.visible = true
		tutorial_drag_tower.z_index = 12
		
	if tower_panel_1:
		tower_panel_1.visible = true
		tower_panel_1.z_index = 12
		
	if tower_panel_2:
		tower_panel_2.visible = true
		tower_panel_2.z_index = 12
		
	# Highlight panel tower
	var tower_panel = $Tower_Placement
	if tower_panel:
		# Tambahkan efek highlight
		tower_panel.modulate = Color(1, 1, 0.5, 1)  # Warna kuning muda
	
	print("⏸️ Game paused - Drag tower ke area yang valid!")

# NEW: Fungsi untuk tutorial upgrade
func _show_upgrade_tutorial():
	print("📢 Tutorial Step 3: Upgrade Tower")
	
	# Pause game
	GameSpeedManager.set_game_speed(0.0)
	_set_speed_button_enabled(false)
	_set_start_button_enabled(false)
	
	# Tampilkan sprite tutorial upgrade
	if tutorial_input_blocker:
		tutorial_input_blocker.visible = true
		tutorial_input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tutorial_input_blocker.z_index = 13
	
	if tutorial_input_blocker_2:
		tutorial_input_blocker_2.visible = true
		tutorial_input_blocker_2.mouse_filter = Control.MOUSE_FILTER_STOP
		tutorial_input_blocker_2.z_index = 13
	# Tampilkan sprite tutorial upgrade DI ATAS
	if tutorial_upgrade:
		tutorial_upgrade.visible = true
		tutorial_upgrade.z_index = 14
	
	print("⏸️ Game paused - Klik tower yang sudah terpasang untuk upgrade!")

# NEW: Fungsi untuk selesaikan tutorial
func _complete_tutorial():
	print("✅ Tutorial Level 1 SELESAI!")
	
	# Sembunyikan semua tutorial sprites
	if tutorial_startwave:
		tutorial_startwave.visible = false
	if tutorial_drag_tower:
		tutorial_drag_tower.visible = false
	if tutorial_upgrade:
		tutorial_upgrade.visible = false
	if tutorial_input_blocker_2:
		tutorial_input_blocker_2.visible = false
	
	# Reset highlight tower panel
	var tower_panel = $CanvasLayer/UI_Management/Panel
	if tower_panel:
		tower_panel.modulate = Color.WHITE
	
	# Resume game
	GameSpeedManager.set_game_speed(1.0)
	_set_speed_button_enabled(true)
	_set_start_button_enabled(true)
	tutorial_step = 4  # Mark as completed

func _show_level1_tutorial():
	# NEW: Tutorial sederhana untuk Level 1
	print("📢 Tutorial Level 1 aktif")
	
	if tutorial_input_blocker:
		tutorial_input_blocker.visible = true
		tutorial_input_blocker.z_index = 0  # Pastikan di bawah
	
	# Tampilkan tutorial label DI ATAS blocker
	if tutorial_startwave:
		tutorial_startwave.visible = true
		tutorial_startwave.z_index = 10
	
	# Tampilkan button Start Wave
	if start_wave_button:
		start_wave_button.visible = true
		#start_wave_button.text = "START WAVE"
		start_wave_button.z_index = 10
		# Highlight button
	
	# Game tetap paused sampai player tekan button
	GameSpeedManager.set_game_speed(0.0)
	print("⏸️ Game paused - Tunggu player tekan Start Wave")

func _hide_level1_tutorial():
	tutorial_input_blocker.visible = false
	tutorial_input_blocker_2.visible = false
	print("✅ Tutorial Level 1 selesai")
	
	if tutorial_startwave:
		tutorial_startwave.visible = false
	
	# Resume game
	GameSpeedManager.set_game_speed(1.0)

func _on_start_wave_button_pressed():
	# NEW: Untuk Level 1, sembunyikan tutorial dulu
	var current_level = GameManager.current_level
	if current_level == 1:
		if tutorial_step == 1 and tutorial_startwave and tutorial_startwave.visible:
			# Selesaikan step 1
			_hide_level1_tutorial()
			tutorial_completed_steps["start_wave"] = true
			
			# Mulai step 2: Drag Tower
			_start_tutorial_step(2)
			return  # Jangan mulai wave dulu
			
		elif tutorial_step == 2 and not tutorial_completed_steps["drag_tower"]:
			print("⚠️ Selesaikan tutorial drag tower dulu!")
			return  # Blok jika belum selesaikan drag tower
			
	if current_level == 1 and tutorial_step == 3 and not first_wave_finished:
		print("⚠️ Selesaikan wave pertama dulu!")
		return
	if not is_countdown_active:
		return
	
	# Hitung reward
	_calculate_wave_reward()
	
	# Berikan reward
	if wave_reward > 0:
		GameManager._add_coin(wave_reward)
		_show_reward_popup(wave_reward)
	
	# Hentikan countdown
	is_countdown_active = false
	if circular_progress:
		circular_progress.visible = false
	if circular_progress2:
		circular_progress2.visible = false
	if start_wave_button:
		start_wave_button.visible = false
	if start_wave_button2:
		start_wave_button2.visible = false
	if pathway_sprite:
			pathway_sprite.visible = false
	
	# Mulai wave
	wave_manager.start_next_wave()
	has_started_first_wave = true

func _on_wave_completed(wave_number: int):
	if GameManager.current_level == 1:
		if wave_number == 1 and not first_wave_finished:
			first_wave_finished = true
			print("🎉 Wave 1 selesai! Buka tutorial upgrade...")
			if GameManager.placed_towers.size() > 0:
				var first_tower = GameManager.placed_towers[0]
				if is_instance_valid(first_tower):
					# Tampilkan tutorial upgrade di atas tower
					if tutorial_upgrade:
						tutorial_upgrade.global_position = first_tower.global_position + Vector2(0, -80)
						tutorial_upgrade.visible = true
			# Jika masih di tutorial step 2, lanjut ke step 3
				if tutorial_step == 2:
					_start_tutorial_step(3)
				
func check_tower_placed():
	if GameManager.current_level == 1 and tutorial_step == 2:
		if GameManager.placed_towers.size() > 0:
			print("✅ Tutorial Step 2 selesai! Tower berhasil ditempatkan.")
			tutorial_completed_steps["drag_tower"] = true
			
			_set_speed_button_enabled(true)
			_set_start_button_enabled(true)
			_set_tower_panel_popup_enabled(true)
			# Sembunyikan tutorial drag tower
			if tutorial_drag_tower:
				tutorial_drag_tower.visible = false
			
			# Reset tower panel highlight
			var tower_panel = $Tower_Placement
			if tower_panel:
				tower_panel.modulate = Color.WHITE
			
			if tutorial_input_blocker:
				tutorial_input_blocker.visible = false
				
			if start_wave_button:
				start_wave_button.visible = true
				#start_wave_button.text = "START WAVE 1"
				
			tutorial_step = 2.5
			
			GameSpeedManager.set_game_speed(1.0)

func _set_tower_panel_popup_enabled(enabled: bool):
	# Cari semua tower panel di scene
	var tower_panels = get_tree().get_nodes_in_group("tower_panel")
	for panel in tower_panels:
		if panel.has_method("set_popup_enabled"):
			panel.set_popup_enabled(enabled)
			
func _on_all_enemies_defeated():
	if GameManager.current_level == 1:
		# Cek wave mana yang selesai
		var current_wave = wave_manager.current_wave
		if current_wave == 1 and not first_wave_finished:  # Wave pertama selesai
			_on_wave_completed(1)
			
func check_tower_clicked():
	if GameManager.current_level == 1 and tutorial_step == 3:
		# Cek jika panel upgrade terlihat
		if ui_upgrade.visible:
			print("✅ Tutorial Step 3 selesai! Panel upgrade terbuka.")
			tutorial_completed_steps["upgrade_tower"] = true
			
			if tutorial_input_blocker:
				tutorial_input_blocker.visible = false
			# Sembunyikan tutorial upgrade
			if tutorial_upgrade:
				tutorial_upgrade.visible = false
			
			# Selesaikan tutorial
			_start_tutorial_step(4)
			return
				
func _start_wave_countdown():
	current_countdown_timer = 0.0
	is_countdown_active = true
	
	if start_wave_button:
		start_wave_button.visible = true
		_update_start_wave_button_text()
	if start_wave_button2:
		start_wave_button2.visible = (GameManager.current_level >= 4)
	if pathway_sprite:
		pathway_sprite.visible = true
	if circular_progress:
		circular_progress.visible = true
		circular_progress.value = max_countdown_time
	if circular_progress2:
		circular_progress2.visible = (GameManager.current_level >= 4)
		if circular_progress2.visible:
			circular_progress2.value = max_countdown_time
	
	countdown_label.visible = true
	_start_visual_countdown()
	
func _start_visual_countdown():
	var countdown_time = max_countdown_time
	
	for i in range(countdown_time, 0, -1):
		if not is_countdown_active:
			break
		countdown_label.text = str(i)
		var remaining_time = i
		if circular_progress:
			circular_progress.value = remaining_time
		if circular_progress2:
			circular_progress2.value = remaining_time
		await get_tree().create_timer(1.0).timeout
	
	if is_countdown_active:
		countdown_label.text = "0"
		if circular_progress:
			circular_progress.value = 0
		if circular_progress2:
			circular_progress2.value = 0
		await get_tree().create_timer(1.0).timeout
		
		# SEMBUNYIKAN SPRITE COUNTDOWN SAAT SELESAI
		if pathway_sprite:
			pathway_sprite.visible = false
		if circular_progress:
			circular_progress.visible = false
		if circular_progress2:
			circular_progress2.visible = false
		
		is_countdown_active = false
		if start_wave_button:
			start_wave_button.visible = false
		
		wave_manager.start_next_wave()
		has_started_first_wave = true
	
	countdown_label.visible = false

func _calculate_wave_reward():
	var remaining_time = max_countdown_time - current_countdown_timer
	var reward_percentage = remaining_time / max_countdown_time
	
	wave_reward = int(max_reward * reward_percentage)
	wave_reward = max(5, wave_reward)
	
	print("💰 Wave reward: ", wave_reward, " gold")

func _update_start_wave_button_text():
	if start_wave_button and is_countdown_active:
		var remaining_time = max_countdown_time - current_countdown_timer
		var reward = int(max_reward * (remaining_time / max_countdown_time))
		reward = max(5, reward)
		
		#start_wave_button.text = "START WAVE NOW\n+" + str(reward) + " GOLD"
		if circular_progress:
			circular_progress.value = remaining_time
		if circular_progress2:
			circular_progress2.value = remaining_time

func _show_reward_popup(amount: int):
	var reward_popup = Label.new()
	reward_popup.text = "+" + str(amount) + " GOLD!"
	reward_popup.add_theme_font_size_override("font_size", 32)
	reward_popup.add_theme_color_override("font_color", Color.GOLD)
	reward_popup.position = Vector2(500, 300)
	
	add_child(reward_popup)
	
	var tween = create_tween()
	tween.tween_property(reward_popup, "position:y", 250, 0.5)
	tween.tween_property(reward_popup, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	reward_popup.queue_free()
	
	print("🎉 Reward: +", amount, " gold!")

# ... (fungsi-fungsi lainnya tetap sama, dari _update_speed_button_text sampai akhir)

func _update_speed_button_text():
	if not speed_button:
		return
	
	var is_fast = GameSpeedManager.is_fast_forward()
	
	if is_fast:
		speed_button.texture_normal = preload("res://asset/fast_forward_x2.png")
	else:
		speed_button.texture_normal = preload("res://asset/fast_forward.png")

func _input(event):
	if event.is_action_pressed("toggle_speed"):
		_on_speed_button_pressed()
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
		
func _on_game_over():
	gameover_panel.visible = true
	#score.text = str(GameManager.coin)

func _on_victory_achieved():
	victory_panel.visible = true
	#score_result.text = str(GameManager.coin)
	
	var stars_earned = calculate_stars()
	show_stars(stars_earned)
	GameSpeedManager.set_game_speed(0.0)
	
	_save_level_completion(stars_earned)

func _save_level_completion(stars: int):
	var current_level = GameManager.current_level
	
	# Gunakan SaveManager Autoload
	SaveManager.complete_level(current_level, stars)
	
	print("🎮 Level ", current_level, " completed (", stars, " stars)")
	
func flash_base_simple():
	if not base_sprite:
		return
	
	var tween = create_tween()
	tween.tween_property(base_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(base_sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(base_sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(base_sprite, "modulate", Color.WHITE, 0.1)
	
func _on_wave_changed(current_wave: int, total_waves: int):
	if wave_lbl:
		wave_lbl.text = "%d/%d" % [current_wave, total_waves]

func _reset_game():
	GameManager.reset_game()
	game_started = false
	
	current_countdown_timer = 0.0
	is_countdown_active = false
	has_started_first_wave = false
	wave_reward = 0
	
	tutorial_step = 0
	tutorial_completed_steps = {
		"start_wave": false,
		"drag_tower": false,
		"upgrade_tower": false
	}
	tutorial_wave_completed = false
	first_wave_finished = false
	
	wave_manager.reset_wave_manager()
	gameover_panel.visible = false
	victory_panel.visible = false
	pause_panel.visible = false
	
	if base_sprite:
		base_sprite.modulate = Color.WHITE
	
	get_tree().call_group("player", "queue_free")
	get_tree().call_group("tower", "queue_free")
	
	countdown_label.visible = false
	
	if circular_progress:
		circular_progress.visible = false
		circular_progress.value = max_countdown_time
	if circular_progress2:
		circular_progress2.visible = false
		circular_progress2.value = max_countdown_time
	if tutorial_startwave:
		tutorial_startwave.visible = false
	if tutorial_drag_tower:
		tutorial_drag_tower.visible = false
	if tutorial_upgrade:
		tutorial_upgrade.visible = false
	
	if start_wave_button:
		start_wave_button.visible = true
		#start_wave_button.text = "START WAVE"
		start_wave_button.remove_theme_color_override("font_color")
		start_wave_button.add_theme_constant_override("outline_size", 0)
	if start_wave_button2:
		start_wave_button2.visible = true
	
	# Reset tower panel highlight
	var tower_panel = $CanvasLayer/UI_Management/Tower_Panel
	if tower_panel:
		tower_panel.modulate = Color.WHITE
	
	GameSpeedManager.set_game_speed(1.0)
	
func _on_restart_button_pressed():
	_reset_game()

func _on_pause_restart_button_pressed():
	print("🔄 Restart dari panel pause")
	_on_pause_pressed()  # Tutup panel pause dulu
	_reset_game()
	
func _on_continue_pressed() -> void:
	GameManager.reset_game()
	GameSpeedManager.set_game_speed(1.0)
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scene/select_level.tscn")

func _on_pause_pressed() -> void:
	GameManager.toggle_pause()
	
func _on_game_paused(is_paused: bool):
	if is_paused:
		pause_panel.visible = true
	else:
		pause_panel.visible = false

func _on_main_menu_pressed() -> void:
	GameManager.reset_game()
	GameSpeedManager.reset_speed()
	GameSpeedManager.set_game_speed(1.0)
	get_tree().change_scene_to_file("res://scene/main_menu.tscn")

func _set_speed_button_enabled(enabled: bool):
	if speed_button:
		speed_button.disabled = not enabled

func _set_start_button_enabled(enabled: bool):
	if start_wave_button:
		start_wave_button.disabled = not enabled
	if start_wave_button2:
		start_wave_button2.disabled = not enabled
		
func _on_wave_countdown_started(seconds: int):
	pass

func _on_wave_countdown_updated(seconds: int):
	pass

func _on_wave_countdown_finished():
	pass
	
func calculate_stars() -> int:
	var health_percentage = float(GameManager.health_player) / 100.0 * 100
	
	if health_percentage >= 100:
		return 3
	elif health_percentage >= 50:
		return 2
	elif health_percentage >= 25:
		return 1
	else:
		return 0

func show_stars(stars_count: int):
	star_1_fill.visible = false
	star_1_blank.visible = true
	star_2_fill.visible = false
	star_2_blank.visible = true
	star_3_fill.visible = false
	star_3_blank.visible = true
	
	match stars_count:
		3:
			star_1_fill.visible = true
			star_2_fill.visible = true
			star_3_fill.visible = true
			star_1_blank.visible = false
			star_2_blank.visible = false
			star_3_blank.visible = false
		2:
			star_1_fill.visible = true
			star_2_fill.visible = true
			star_3_fill.visible = false
			star_1_blank.visible = false
			star_2_blank.visible = false
			star_3_blank.visible = true
		1:
			star_1_fill.visible = true
			star_2_fill.visible = false
			star_3_fill.visible = false
			star_1_blank.visible = false
			star_2_blank.visible = true
			star_3_blank.visible = true
		0:
			star_1_fill.visible = false
			star_2_fill.visible = false
			star_3_fill.visible = false
			star_1_blank.visible = true
			star_2_blank.visible = true
			star_3_blank.visible = true

func show_tower_info(tower_reference):
	current_tower = tower_reference
	_reset_all_panel_info()
	var tower_pos = current_tower.global_position
	var viewport_size = get_viewport().size
	
	# Estimasi posisi di layar (asumsi kamera di 0,0)
	is_tower_on_left_side = tower_pos.x < viewport_size.x / 2
	
	print("📌 Tower di ", "KIRI" if is_tower_on_left_side else "KANAN", 
		  " layar - Posisi X: ", tower_pos.x)
	
	# Posisikan panel upgrade
	if ui_upgrade:
		ui_upgrade.global_position = current_tower.global_position
		
		# Sesuaikan posisi panel
		var panel_offset = Vector2(0, 0)  # Naik sedikit
		if is_tower_on_left_side:
			panel_offset.x = 0  # Geser ke kanan jika tower di kiri
		else:
			panel_offset.x = 0  # Geser ke kiri jika tower di kanan
		
		ui_upgrade.global_position += panel_offset
	
	ui_upgrade.visible = true
	update_tower_display()
	_update_panel_info_position()
	
	if GameManager.current_level == 1 and tutorial_step == 3:
		check_tower_clicked()

func _reset_all_panel_info():
	# Reset semua panel info ke false
	if sell_info:
		sell_info.visible = false
	if upgrade_info:
		upgrade_info.visible = false
	if panel_sell_2:
		panel_sell_2.visible = false
	if panel_upgrade_2:
		panel_upgrade_2.visible = false
	
	print("🔄 Semua panel info di-reset")
	
func _update_panel_info_position():
	if not current_tower:
		return
	
	# Nonaktifkan semua panel info dulu
	if sell_info:
		sell_info.visible = false
	if upgrade_info:
		upgrade_info.visible = false
	if panel_sell_2:
		panel_sell_2.visible = false
	if panel_upgrade_2:
		panel_upgrade_2.visible = false
	
	# Aktifkan panel yang sesuai berdasarkan posisi tower
	if is_tower_on_left_side:
		# Tower di KIRI → gunakan panel kanan (panel_sell_2, panel_upgrade_2)
		if panel_sell_2:
			panel_sell_2.visible = false
		if panel_upgrade_2:
			panel_upgrade_2.visible = false
		if label_ket2 and current_tower:
			label_ket2.text = _get_tower_description(current_tower.tower_type)
		print("📌 Menggunakan panel info KANAN")
	else:
		# Tower di KANAN → gunakan panel kiri (sell_info, upgrade_info)
		if sell_info:
			sell_info.visible = false
		if upgrade_info:
			upgrade_info.visible = false
		if label_ket and current_tower:
			label_ket.text = _get_tower_description(current_tower.tower_type)
		print("📌 Menggunakan panel info KIRI")

func _update_tower_description():
	if current_tower:
		var description = _get_tower_description(current_tower.tower_type)
		
		if label_ket:
			label_ket.text = description 
		if label_ket2:
			label_ket2.text = description 
			
func update_tower_display():
	if current_tower:
		if tower_name_label:
			var display_name = current_tower.tower_type.replace("_", " ")
			tower_name_label.text = display_name + " (Lv." + str(current_tower.upgrade_level) + ")"
		if tower_name_label2:
			var display_name = current_tower.tower_type.replace("_", " ")
			tower_name_label2.text = display_name + " (Lv." + str(current_tower.upgrade_level) + ")"
		if tower_name_label3:
			var display_name = current_tower.tower_type.replace("_", " ")
			tower_name_label3.text = display_name + " (Lv." + str(current_tower.upgrade_level) + ")"
		if tower_name_label4:
			var display_name = current_tower.tower_type.replace("_", " ")
			tower_name_label4.text = display_name + " (Lv." + str(current_tower.upgrade_level) + ")"
		
		if label_ket:
			label_ket.text = _get_tower_description(current_tower.tower_type)
		if label_ket2:
			label_ket2.text = _get_tower_description(current_tower.tower_type)
		
		if upgrade_cost_label:
			var upgrade_cost = current_tower.get_upgrade_cost()
			if upgrade_cost == 99999:
				upgrade_cost_label.text = "MAX LEVEL"
				if upgrade_button:
					upgrade_button.disabled = true
					upgrade_button.text = "MAX LEVEL"
					_show_max_level_stats()
			else:
				upgrade_cost_label.text = str(upgrade_cost)
				if upgrade_button:
					upgrade_button.disabled = false
					_update_upgrade_stats_display()
		
		if upgrade_cost_label2:
			var upgrade_cost = current_tower.get_upgrade_cost()
			if upgrade_cost == 99999:
				upgrade_cost_label2.text = "MAX LEVEL"
				if upgrade_button:
					upgrade_button.disabled = true
					upgrade_button.text = "MAX LEVEL"
					_show_max_level_stats()
			else:
				upgrade_cost_label2.text = str(upgrade_cost)
				if upgrade_button:
					upgrade_button.disabled = false
					_update_upgrade_stats_display()
		
		if sell_price_label:
			var sell_price = calculate_sell_price(current_tower)
			sell_price_label.text = str(sell_price)
		
		if sell_price_label2:
			var sell_price = calculate_sell_price(current_tower)
			sell_price_label2.text = str(sell_price)

		# Enable sell button
		if sell_button:
			sell_button.disabled = false
		
		_update_current_stats_display()

func _get_texture_key_for_level(level: int) -> String:
	match level:
		1: return "level1"
		2: return "level2"
		3: return "level3"
		_: return "level1"
		
func _show_max_level_stats():
	if next_damage_label:
		next_damage_label.text = "MAX"
		next_damage_label.visible = true
	if next_range_label:
		next_range_label.text = "MAX"
		next_range_label.visible = true
	if next_cooldown_label:
		next_cooldown_label.text = "MAX"
		next_cooldown_label.visible = true
	if next_damage_label2:
		next_damage_label2.text = "MAX"
		next_damage_label2.visible = true
	if next_range_label2:
		next_range_label2.text = "MAX"
		next_range_label2.visible = true
	if next_cooldown_label2:
		next_cooldown_label2.text = "MAX"
		next_cooldown_label2.visible = true
		
func _update_current_stats_display():
	if current_tower:
		# Ambil data langsung dari CSV via method tower
		if current_tower.has_method("get_current_stat_from_csv"):
			var current_damage = current_tower.get_current_stat_from_csv("damage")
			var current_range = current_tower.get_current_stat_from_csv("range")
			var current_cooldown = current_tower.get_current_stat_from_csv("cooldown")
			
			current_damage_label.text = str(snapped(current_damage, 0.1))
			current_range_label.text = str(snapped(current_range, 0.1))
			current_cooldown_label.text = str(snapped(current_cooldown, 0.1))
			current_damage_label2.text = str(snapped(current_damage, 0.1))
			current_range_label2.text = str(snapped(current_range, 0.1))
			current_cooldown_label2.text = str(snapped(current_cooldown, 0.1))

# Fungsi baru untuk update stats setelah upgrade
func _update_upgrade_stats_display():
	if current_tower:
		var current_level = current_tower.upgrade_level
		
		if current_level < 3:  # Bisa di-upgrade ke level berikutnya
			# Cek jika tower memiliki method untuk ambil dari CSV
			if current_tower.has_method("get_next_stat_from_csv"):
				var next_damage = current_tower.get_next_stat_from_csv("damage")
				var next_range = current_tower.get_next_stat_from_csv("range")
				var next_cooldown = current_tower.get_next_stat_from_csv("cooldown")
				
				next_damage_label.text = str(snapped(next_damage, 0.1))
				next_range_label.text = str(snapped(next_range, 0.1))
				next_cooldown_label.text = str(snapped(next_cooldown, 0.1))
				next_damage_label2.text = str(snapped(next_damage, 0.1))
				next_range_label2.text = str(snapped(next_range, 0.1))
				next_cooldown_label2.text = str(snapped(next_cooldown, 0.1))
		else:
			# Max level
			next_damage_label.text = "MAX"
			next_range_label.text = "MAX"
			next_cooldown_label.text = "MAX"
			next_damage_label2.text = "MAX"
			next_range_label2.text = "MAX"
			next_cooldown_label2.text = "MAX"
			
func _show_next_upgrade_stats():
	if next_damage_label:
		next_damage_label.visible = true
	if next_range_label:
		next_range_label.visible = true
	if next_cooldown_label:
		next_cooldown_label.visible = true
	_update_upgrade_stats_display()
		
func _on_upgrade_button_pressed():
	current_tower.upgrade_tower()
	update_tower_display()

func calculate_sell_price(tower) -> int:
	# Hitung total biaya yang sudah dikeluarkan
	var base_cost = tower.get_base_cost()
	var total_spent = base_cost
	
	# Tambahkan biaya upgrade jika ada
	if tower.upgrade_level >= 2:
		total_spent += tower.upgrade_cost_level2
	if tower.upgrade_level >= 3:
		total_spent += tower.upgrade_cost_level3
	
	# Kembalikan 70% dari total biaya
	var sell_price = int(total_spent * 0.7)
	return max(5, sell_price)  # Minimal 5 coins

# Tambahkan fungsi untuk handle sell button
func _on_sell_button_pressed():
	if not current_tower:
		return
	
	# Hitung harga jual
	var sell_price = calculate_sell_price(current_tower)
	
	# Tambahkan koin ke player
	GameManager._add_coin(sell_price)
	print("✅ Tower dijual seharga ", sell_price, " coins")
	
	# Hapus tower dari daftar dan scene
	if current_tower in GameManager.placed_towers:
		GameManager.placed_towers.erase(current_tower)
	
	current_tower.queue_free()
	current_tower = null
	
	# Tutup panel upgrade
	ui_upgrade.visible = false
	
func format_tower_name(tower_type: String) -> String:
	match tower_type:
		"Stove_Cannon":
			return "Stove Cannon"
		"Chilli_Launcher":
			return "Chilli Launcher" 
		"Ice_Chiller":
			return "Ice Chiller"
		"Pepper_Grinder":
			return "Pepper Grinder"
		"Garlic":
			return "Garlic Tower"
		_:
			return tower_type.replace("_", " ")

func _get_tower_description(tower_type: String) -> String:
	match tower_type:
		"Stove_Cannon":
			return "Damage tembakan meningkat, lebih efektif melawan 
			musuh kuat. "
		"Chilli_Launcher":
			return "Menyerang musuh dengan lebih cepat dari jarak jauh, 
			efektif untuk menghadapi banyak musuh"
		"Ice_Chiller":
			return "Durasi freeze bertambah, musuh lebih lama terhenti."
		"Pepper_Grinder":
			return "Durasi blind lebih lama, musuh lebih lama berhenti 
			menyerang."
		"Garlic_Barrier":
			return "Area slow lebih luas dan bertahan lebih lama."
		_:
			return "Tower dengan kemampuan khusus."
			
func _on_close_upgrade_panel_pressed():
	ui_upgrade.visible = false
	current_tower = null
	
func _on_quit_pressed() -> void:
	print("quit")

func _on_resume_pressed() -> void:
	GameManager.toggle_pause()


func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/select_level.tscn")
	GameManager.should_open_store = true


func _on_setting_pressed() -> void:
	panel_settings.visible = true
	if slider_music:
		slider_music.value = MusicPlayer.volume

func _on_close_settings_pressed() -> void:
	panel_settings.visible = false
	
func _on_slider_music_value_changed(value: float) -> void:
	MusicPlayer.set_bgm_volume(value)

# Fungsi untuk ketika volume music berubah dari luar
func _on_music_volume_changed(value: float):
	if slider_music and slider_music.value != value:
		slider_music.value = value

func _on_sell_pressed():
	_reset_all_panel_info()
	if is_tower_on_left_side:
		# Tower di kiri → gunakan panel_sell_2
		if panel_sell_2:
			panel_sell_2.visible = !panel_sell_2.visible
			print("📢 Panel sell KANAN: ", panel_sell_2.visible)
	else:
		# Tower di kanan → gunakan sell_info
		if sell_info:
			sell_info.visible = !sell_info.visible
			print("📢 Panel sell KIRI: ", sell_info.visible)

func _on_upgrade_pressed():
	_reset_all_panel_info()
	if is_tower_on_left_side:
		# Tower di kiri → gunakan panel_upgrade_2
		if panel_upgrade_2:
			panel_upgrade_2.visible = !panel_upgrade_2.visible
			print("📢 Panel upgrade KANAN: ", panel_upgrade_2.visible)
	else:
		# Tower di kanan → gunakan upgrade_info
		if upgrade_info:
			upgrade_info.visible = !upgrade_info.visible
			print("📢 Panel upgrade KIRI: ", upgrade_info.visible)
