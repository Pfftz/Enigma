extends Node2D

# Signal for completing the minigame
signal minigame_completed(final_score: int)

var BubbleScene = preload("res://scenes/core_game/bubble.tscn")
var TrapBubbleScene = preload("res://scenes/core_game/positive_bubble.tscn")
var GoldenBubbleScene = preload("res://scenes/core_game/golden_bubble.tscn")

var positive_words = ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX", "FOKUS", "SABAR"]
var trap_words = ["RAGU", "LEMAH", "TAKUT", "KALAH", "GUSAR", "PUTUS", "BICIK"]

var active_bubbles = []
var target_bubble = null
var current_typed_string = ""
var score = 0
var is_ultimate_triggered = false

# --- PENGATURAN KESULITAN ---
@export_range(2, 6) var number_of_bubbles: int = 6
@export var gameplay_duration: float = 20.0
@export var bubble_replace_interval: float = 2.0
@export_range(0.0, 1.0) var trap_chance: float = 0.25
@export var min_pop_respawn_delay: float = 2.0
@export var max_pop_respawn_delay: float = 3.0

# --- PENGATURAN FITUR ULTIMATE ---
@export var ultimate_score_threshold: int = 50
@export var ultimate_spam_count: int = 15

# --- PENGATURAN LAYOUT ---
@export var horizontal_margin_percent = 0.2
@export var vertical_margin_percent = 0.2
@export var middle_bubble_offset = 0.05
@export var outer_bubble_offset = 0.03

# --- REFERENSI NODE ---
@onready var game_status_label = $GameStatusLabel
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var gameplay_timer = $GameplayTimer
@onready var bubble_respawn_timer = $BubbleRespawnTimer
@onready var player_input_label = $PlayerInputLabel
@onready var instruction_label = $InstructionLabel
@onready var ultimate_announce_label = $UltimateAnnounceLabel

func _ready():
	randomize()
	start_new_game()

func start_new_game():
	score = 0
	is_ultimate_triggered = false
	update_score_display()
	time_label.text = "Waktu: %.1f" % gameplay_duration
	game_status_label.hide()
	instruction_label.hide()
	ultimate_announce_label.hide()
	gameplay_timer.stop()
	bubble_respawn_timer.stop()
	
	for b in get_tree().get_nodes_in_group("normal_bubbles"): b.queue_free()
	for b in get_tree().get_nodes_in_group("trap_bubbles"): b.queue_free()
	if get_tree().get_nodes_in_group("golden_bubble").size() > 0:
		for b in get_tree().get_nodes_in_group("golden_bubble"): b.queue_free()
	active_bubbles.clear()
	
	do_countdown()

# (MODIFIKASI TOTAL) Fungsi ini sekarang memunculkan balon secara bertahap.
func do_countdown():
	game_status_label.show()
	
	# --- TAHAP 1: KONTEKS NARATIF ---
	game_status_label.text = "PERTANYAAN MACAM APA ITU?"
	await get_tree().create_timer(2.5).timeout
	
	game_status_label.text = "singkirkan pikiran intrusif mu"
	await get_tree().create_timer(2.5).timeout
	
	# --- TAHAP 2: PERSIAPAN BALON (TIDAK TERLIHAT) ---
	var positions = get_bubble_positions()
	var initial_trap_count = 1 if number_of_bubbles > 4 else 0
	var initial_words = generate_unique_word_set(initial_trap_count)
	
	# --- TAHAP 3: HITUNG MUNDUR & SPAWN BERTAHAP ---
	var bubbles_per_step = number_of_bubbles / 3
	var spawned_count = 0
	
	game_status_label.text = "3"
	for i in range(bubbles_per_step):
		if spawned_count < initial_words.size():
			var word_data = initial_words[spawned_count]
			var pos = positions[spawned_count]
			spawn_new_bubble(pos, word_data.word, word_data.is_trap)
			spawned_count += 1
	await get_tree().create_timer(1.0).timeout
	
	game_status_label.text = "2"
	for i in range(bubbles_per_step):
		if spawned_count < initial_words.size():
			var word_data = initial_words[spawned_count]
			var pos = positions[spawned_count]
			spawn_new_bubble(pos, word_data.word, word_data.is_trap)
			spawned_count += 1
	await get_tree().create_timer(1.0).timeout
	
	game_status_label.text = "1"
	# Spawn sisa balon di hitungan terakhir
	while spawned_count < initial_words.size():
		var word_data = initial_words[spawned_count]
		var pos = positions[spawned_count]
		spawn_new_bubble(pos, word_data.word, word_data.is_trap)
		spawned_count += 1
	await get_tree().create_timer(1.0).timeout
	
	game_status_label.text = "GO!"
	await get_tree().create_timer(0.5).timeout
	
	game_status_label.hide()
	
	# --- TAHAP 4: MULAI PERMAINAN ---
	gameplay_timer.wait_time = gameplay_duration
	bubble_respawn_timer.wait_time = bubble_replace_interval
	gameplay_timer.start()
	bubble_respawn_timer.start()

func trigger_ultimate():
	is_ultimate_triggered = true
	
	gameplay_timer.stop()
	bubble_respawn_timer.stop()
	
	for bubble in active_bubbles:
		bubble.queue_free()
	active_bubbles.clear()
	
	player_input_label.hide()
	
	ultimate_announce_label.show()
	ultimate_announce_label.text = "ULTIMATE!"
	await get_tree().create_timer(1.5).timeout
	ultimate_announce_label.hide()
	
	instruction_label.text = "MASH SPACE BUTTON"
	instruction_label.show()
	
	var screen_center = get_viewport_rect().size / 2
	var golden_bubble = GoldenBubbleScene.instantiate()
	golden_bubble.add_to_group("golden_bubble")
	golden_bubble.ultimate_bubble_popped.connect(_on_ultimate_bubble_popped)
	golden_bubble.global_position = screen_center
	golden_bubble.setup(ultimate_spam_count)
	add_child(golden_bubble)
	active_bubbles.append(golden_bubble)
	golden_bubble.play_spawn_animation()
	
	target_bubble = golden_bubble

func _on_ultimate_bubble_popped():
	game_status_label.show()
	game_status_label.text = "SELAMAT!\nKamu berhasil!"
	instruction_label.hide()
	
	# Wait 2 seconds before emitting the completion signal
	await get_tree().create_timer(2.0).timeout
	
	# Emit the minigame completion signal with the final score
	minigame_completed.emit(score)
	print("DEBUG: Ultimate completed! Emitting minigame_completed signal with score: ", score)

# Dulu ada spawn_initial_bubbles(), sekarang logikanya sudah pindah ke do_countdown()

func spawn_new_bubble(pos: Vector2, word: String, is_trap: bool):
	var scene_to_use = TrapBubbleScene if is_trap else BubbleScene
	var new_bubble = scene_to_use.instantiate()
	
	# (FIX) Atur skala ke nol SEBELUM menambahkannya ke scene untuk mencegah flicker.
	new_bubble.get_node("Sprite2D").scale = Vector2.ZERO
	
	new_bubble.popped.connect(_on_bubble_popped)
	
	new_bubble.global_position = pos
	new_bubble.setup(word)
	add_child(new_bubble)
	active_bubbles.append(new_bubble)
	
	new_bubble.play_spawn_animation()

func get_word_for_new_bubble() -> Dictionary:
	var used_letters = []
	for b in active_bubbles:
		if is_instance_valid(b): used_letters.append(b.positive_affirmation[0])

	var is_trap = randf() < trap_chance
	var word_list = trap_words if is_trap else positive_words
	word_list.shuffle()
	
	var new_word = ""
	for word in word_list:
		if not word[0] in used_letters:
			new_word = word
			break
	
	if new_word == "":
		if not word_list.is_empty(): new_word = word_list[0]
		else: return {"word": "ERROR", "is_trap": true}

	return {"word": new_word, "is_trap": is_trap}

func _process(_delta):
	if not gameplay_timer.is_stopped(): update_time_label()

func update_time_label():
	time_label.text = "Waktu: %.1f" % gameplay_timer.time_left

func _on_gameplay_timer_timeout():
	game_over()

func _on_bubble_respawn_timer_timeout():
	if active_bubbles.is_empty(): return
	
	var bubble_to_replace = active_bubbles.pick_random()
	var pos = bubble_to_replace.global_position
	
	active_bubbles.erase(bubble_to_replace)
	bubble_to_replace.queue_free()
	
	var new_word_data = get_word_for_new_bubble()
	spawn_new_bubble(pos, new_word_data.word, new_word_data.is_trap)
	
	bubble_respawn_timer.start()

func _on_bubble_popped(pos: Vector2):
	var delay = randf_range(min_pop_respawn_delay, max_pop_respawn_delay)
	await get_tree().create_timer(delay).timeout
	
	if gameplay_timer.is_stopped(): return
		
	var new_word_data = get_word_for_new_bubble()
	spawn_new_bubble(pos, new_word_data.word, new_word_data.is_trap)
	
	bubble_respawn_timer.start()

func game_over():
	if is_ultimate_triggered: return

	gameplay_timer.stop()
	bubble_respawn_timer.stop()
	
	for bubble in active_bubbles:
		bubble.queue_free()
	active_bubbles.clear()
	
	game_status_label.show()
	game_status_label.text = "Waktu Habis!\nSkor Akhir: %d" % score
	
	# Wait 2 seconds before emitting the completion signal
	await get_tree().create_timer(2.0).timeout
	
	# Emit the minigame completion signal with the final score
	minigame_completed.emit(score)
	print("DEBUG: Emitting minigame_completed signal with score: ", score)

func generate_unique_word_set(trap_count: int) -> Array:
	var final_words = []
	var used_first_letters = {}
	positive_words.shuffle()
	trap_words.shuffle()
	
	var traps_added = 0
	for t_word in trap_words:
		if traps_added >= trap_count: break
		if not used_first_letters.has(t_word[0]):
			final_words.append({"word": t_word, "is_trap": true})
			used_first_letters[t_word[0]] = true
			traps_added += 1
			
	var positives_to_add = number_of_bubbles - traps_added
	var positives_added = 0
	for p_word in positive_words:
		if positives_added >= positives_to_add: break
		if not used_first_letters.has(p_word[0]):
			final_words.append({"word": p_word, "is_trap": false})
			used_first_letters[p_word[0]] = true
			positives_added += 1
			
	final_words.shuffle()
	return final_words

func get_bubble_positions() -> Array:
	var positions = []
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2.0
	
	match number_of_bubbles:
		6:
			var top_y = screen_size.y * vertical_margin_percent
			var bottom_y = screen_size.y * (1.0 - vertical_margin_percent)
			var usable_height = bottom_y - top_y
			var y_positions = [top_y, top_y + usable_height / 2, bottom_y]
			var base_left_x = screen_size.x * horizontal_margin_percent
			var base_right_x = screen_size.x * (1.0 - horizontal_margin_percent)
			for i in range(3):
				var x_pos = base_left_x
				if i == 1: x_pos -= screen_size.x * middle_bubble_offset
				else: x_pos += screen_size.x * outer_bubble_offset
				positions.append(Vector2(x_pos, y_positions[i]))
			for i in range(3):
				var x_pos = base_right_x
				if i == 1: x_pos += screen_size.x * middle_bubble_offset
				else: x_pos -= screen_size.x * outer_bubble_offset
				positions.append(Vector2(x_pos, y_positions[i]))
		4:
			var margin_x = screen_size.x * 0.25
			var margin_y = screen_size.y * 0.2
			positions.append(Vector2(center.x, margin_y))
			positions.append(Vector2(center.x, screen_size.y - margin_y))
			positions.append(Vector2(margin_x, center.y))
			positions.append(Vector2(screen_size.x - margin_x, center.y))
		_:
			var radius_x = center.x * 0.35
			var radius_y = center.y * 0.3
			var angle_step = TAU / number_of_bubbles
			for i in range(number_of_bubbles):
				var angle = angle_step * i
				var x_pos = center.x + cos(angle) * radius_x
				var y_pos = center.y + sin(angle) * radius_y
				positions.append(Vector2(x_pos, y_pos))
				
	return positions

func update_score_display():
	score_label.text = "Skor: %d / %d" % [score, ultimate_score_threshold]

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if gameplay_timer.is_stopped() and not is_ultimate_triggered: return
		handle_typing(event)

func handle_typing(event):
	if is_ultimate_triggered:
		if event.keycode == KEY_SPACE:
			if is_instance_valid(target_bubble) and target_bubble.is_in_group("golden_bubble"):
				target_bubble.register_spam()
		return

	var key_typed = OS.get_keycode_string(event.keycode).to_upper()
	if target_bubble == null:
		for bubble in active_bubbles:
			if is_instance_valid(bubble) and bubble.positive_affirmation.begins_with(key_typed):
				target_bubble = bubble
				current_typed_string = key_typed
				player_input_label.text = current_typed_string
				target_bubble.play_typing_feedback()
				# (FIX) Reset timer penggantian acak setiap kali pemain mengetik.
				bubble_respawn_timer.start()
				return
	else:
		if not is_instance_valid(target_bubble):
			reset_typing()
			return
			
		var potential_string = current_typed_string + key_typed
		if target_bubble.positive_affirmation.begins_with(potential_string):
			current_typed_string = potential_string
			player_input_label.text = current_typed_string
			target_bubble.play_typing_feedback()
			# (FIX) Reset timer penggantian acak setiap kali pemain mengetik.
			bubble_respawn_timer.start()
			if current_typed_string == target_bubble.positive_affirmation:
				if target_bubble.is_in_group("trap_bubbles"): score -= 10
				else: score += 5
				
				update_score_display()
				
				active_bubbles.erase(target_bubble)
				target_bubble.pop()
				
				if score >= ultimate_score_threshold and not is_ultimate_triggered:
					trigger_ultimate()
					
				reset_typing()
		else:
			reset_typing()

func reset_typing():
	target_bubble = null
	current_typed_string = ""
	player_input_label.text = ""
