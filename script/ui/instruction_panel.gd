extends Panel

signal instruction_completed
signal skip_instructions

@export var instruction_csv_path := "res://data/instruction_data.csv"
@export var current_level: int = 1

@onready var continue_button: Button = $HBoxContainer/ContinueButton
@onready var skip_button: Button = $HBoxContainer/SkipButton
@onready var previous_button: Button = $HBoxContainer/PreviousButton

@onready var page1: Panel = $Page1
@onready var page2: Panel = $Page2
@onready var page3: Panel = $Page3
@onready var page4: Panel = $Page4

@onready var page_labels := {
	1: $Page1/InstructionLabel,
	2: $Page2/InstructionLabel,
	3: $Page3/InstructionLabel,
	4: $Page4/InstructionLabel
}

var current_page: int = 1
var instruction_data := {} # { level: { page: text } }

# --------------------------------------------------

func _ready():
	_load_instruction_csv()
	_apply_instruction_text()

	_show_page(1)

	GameSpeedManager.set_game_speed(0.0)
	_update_buttons()

# --------------------------------------------------
# CSV LOADER
# --------------------------------------------------

func _load_instruction_csv():
	var file = FileAccess.open(instruction_csv_path, FileAccess.READ)
	if file == null:
		push_error("Instruction CSV not found")
		return

	file.get_line() # skip header

	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges() == "":
			continue

		var cols = line.split(",", false, 3)
		var level = int(cols[0])
		var page = int(cols[1])
		var text = cols[2]

		if not instruction_data.has(level):
			instruction_data[level] = {}

		instruction_data[level][page] = text

	file.close()

# --------------------------------------------------
# APPLY TEXT
# --------------------------------------------------

func _apply_instruction_text():
	if not instruction_data.has(current_level):
		return

	for page in page_labels.keys():
		page_labels[page].text = instruction_data[current_level].get(page, "")

# --------------------------------------------------
# PAGE CONTROL
# --------------------------------------------------

func _show_page(page: int):
	current_page = page

	page1.visible = page == 1
	page2.visible = page == 2
	page3.visible = page == 3
	page4.visible = page == 4

	_update_buttons()

# --------------------------------------------------
# BUTTON HANDLERS
# --------------------------------------------------

func _on_continue_pressed():
	if current_page < 4:
		_show_page(current_page + 1)
	else:
		GameSpeedManager.set_game_speed(1.0)
		instruction_completed.emit()

func _on_previous_pressed():
	if current_page > 1:
		_show_page(current_page - 1)

func _on_skip_pressed():
	GameSpeedManager.set_game_speed(1.0)
	skip_instructions.emit()

# --------------------------------------------------
# UI STATE
# --------------------------------------------------

func _update_buttons():
	previous_button.visible = current_page > 1

	continue_button.visible = current_page < 4

	if current_page == 1:
		skip_button.visible = true
		skip_button.text = "SKIP"
	elif current_page == 4:
		skip_button.visible = true
		skip_button.text = "GOT IT"
	else:
		skip_button.visible = false
