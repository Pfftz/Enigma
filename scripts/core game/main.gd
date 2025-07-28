extends Node2D

var BubbleScene = preload("res://scenes/core game/bubble.tscn")

# Daftar kalimat positif.
# Pastikan huruf awal tidak ada yang sama.
var positive_words = ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX"]

var active_bubbles = []
var target_bubble = null
var current_typed_string = ""

# --- PENGATURAN LAYOUT ---
@export var horizontal_margin_percent = 0.2
@export var vertical_margin_percent = 0.2
@export var middle_bubble_offset = 0.05
@export var outer_bubble_offset = 0.03

func _ready():
	spawn_bubbles()

func spawn_bubbles():
	positive_words.shuffle()
	var screen_size = get_viewport_rect().size

	var top_y = screen_size.y * vertical_margin_percent
	var bottom_y = screen_size.y * (1.0 - vertical_margin_percent)
	var usable_height = bottom_y - top_y
	var y_positions = [top_y, top_y + usable_height / 2, bottom_y]

	var base_left_x = screen_size.x * horizontal_margin_percent
	var base_right_x = screen_size.x * (1.0 - horizontal_margin_percent)

	# Buat 3 bubble di kiri dengan layout zig-zag.
	for i in range(3):
		var x_pos = base_left_x
		if i == 1:
			x_pos -= screen_size.x * middle_bubble_offset
		else:
			x_pos += screen_size.x * outer_bubble_offset
		create_bubble(Vector2(x_pos, y_positions[i]), positive_words[i])

	# Buat 3 bubble di kanan dengan layout zig-zag.
	for i in range(3):
		var x_pos = base_right_x
		if i == 1:
			x_pos += screen_size.x * middle_bubble_offset
		else:
			x_pos -= screen_size.x * outer_bubble_offset
		create_bubble(Vector2(x_pos, y_positions[i]), positive_words[i + 3])

func create_bubble(pos, word):
	var new_bubble = BubbleScene.instantiate()
	new_bubble.position = pos
	new_bubble.setup(word)
	add_child(new_bubble)
	active_bubbles.append(new_bubble)

# ... (kode di bagian atas tetap sama) ...

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_typed = OS.get_keycode_string(event.keycode).to_upper()

		if target_bubble == null:
			for bubble in active_bubbles:
				if bubble.positive_affirmation.begins_with(key_typed):
					target_bubble = bubble
					current_typed_string = key_typed
					# (BARU) Tampilkan huruf pertama yang diketik
					$PlayerInputLabel.text = current_typed_string
					target_bubble.play_typing_feedback()
					return
		else:
			var potential_string = current_typed_string + key_typed

			if target_bubble.positive_affirmation.begins_with(potential_string):
				current_typed_string = potential_string
				# (BARU) Perbarui tampilan teks input
				$PlayerInputLabel.text = current_typed_string
				target_bubble.play_typing_feedback()

				if current_typed_string == target_bubble.positive_affirmation:
					target_bubble.pop()
					reset_typing()
			else:
				reset_typing()

func reset_typing():
	target_bubble = null
	current_typed_string = ""
	# (BARU) Kosongkan label input saat reset
	$PlayerInputLabel.text = ""
