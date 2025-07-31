extends Control

signal minigame_completed(minigame_score)

var BubbleScene = preload("res://scenes/core_game/bubble.tscn")
var TrapBubbleScene = preload("res://scenes/core_game/positive_bubble.tscn")

var positive_words = ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX", "FOKUS", "SABAR"]
var trap_words = ["RAGU", "LEMAH", "TAKUT", "KALAH", "GUSAR", "PUTUS", "BICIK"]

var active_bubbles = []
var target_bubble = null
var current_typed_string = ""
var score = 0

# --- PENGATURAN GAMEPLAY BARU ---
@export var gameplay_duration: float = 20.0
@export var bubble_replace_interval: float = 2.0
@export_range(0.0, 1.0) var trap_chance: float = 0.25 # 25% kemungkinan trap
@export var min_pop_respawn_delay: float = 2.0
@export var max_pop_respawn_delay: float = 3.0

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

func _ready():
	randomize()
	start_new_game()

func start_new_game():
	score = 0
	score_label.text = "Skor: 0"
	game_status_label.hide()
	
	print("DEBUG: Starting bubble minigame with score: ", score)
	
	# Clean up existing bubbles safely
	for b in get_tree().get_nodes_in_group("normal_bubbles"):
		if is_instance_valid(b):
			b.queue_free()
	for b in get_tree().get_nodes_in_group("trap_bubbles"):
		if is_instance_valid(b):
			b.queue_free()
	active_bubbles.clear()

	spawn_initial_bubbles()
	
	gameplay_timer.wait_time = gameplay_duration
	bubble_respawn_timer.wait_time = bubble_replace_interval
	gameplay_timer.start()
	bubble_respawn_timer.start()
	update_time_label()

func spawn_initial_bubbles():
	var positions = get_bubble_positions()
	var initial_words = generate_unique_word_set(1)
	
	for i in range(positions.size()):
		var pos = positions[i]
		if i < initial_words.size():
			var word_data = initial_words[i]
			spawn_new_bubble(pos, word_data.word, word_data.is_trap)

func spawn_new_bubble(pos: Vector2, word: String, is_trap: bool):
	var scene_to_use = TrapBubbleScene if is_trap else BubbleScene
	var new_bubble = scene_to_use.instantiate()
	
	new_bubble.popped.connect(_on_bubble_popped)
	
	new_bubble.global_position = pos
	new_bubble.setup(word)
	add_child(new_bubble)
	active_bubbles.append(new_bubble)
	
	new_bubble.play_spawn_animation()

func get_word_for_new_bubble() -> Dictionary:
	var used_letters = []
	for b in active_bubbles:
		if is_instance_valid(b):
			used_letters.append(b.positive_affirmation[0])

	var is_trap = randf() < trap_chance
	var word_list = trap_words if is_trap else positive_words
	word_list.shuffle()
	
	var new_word = ""
	for word in word_list:
		if not word[0] in used_letters:
			new_word = word
			break
	
	if new_word == "":
		if not word_list.is_empty():
			new_word = word_list[0]
		else:
			return {"word": "ERROR", "is_trap": true}

	return {"word": new_word, "is_trap": is_trap}

func _process(_delta):
	if not gameplay_timer.is_stopped():
		update_time_label()

func update_time_label():
	time_label.text = "Waktu: %.1f" % gameplay_timer.time_left

func _on_gameplay_timer_timeout():
	game_over()

func _on_bubble_respawn_timer_timeout():
	if active_bubbles.is_empty(): return
	
	var bubble_to_replace = active_bubbles.pick_random()
	
	# Safety check to ensure bubble is still valid
	if not is_instance_valid(bubble_to_replace):
		active_bubbles.erase(bubble_to_replace)
		return
	
	# Store position before freeing the bubble
	var pos = bubble_to_replace.global_position
	
	active_bubbles.erase(bubble_to_replace)
	bubble_to_replace.queue_free()
	
	var new_word_data = get_word_for_new_bubble()
	spawn_new_bubble(pos, new_word_data.word, new_word_data.is_trap)

func _on_bubble_popped(pos: Vector2):
	var delay = randf_range(min_pop_respawn_delay, max_pop_respawn_delay)
	await get_tree().create_timer(delay).timeout
	
	if gameplay_timer.is_stopped():
		return
		
	var new_word_data = get_word_for_new_bubble()
	spawn_new_bubble(pos, new_word_data.word, new_word_data.is_trap)

# Di dalam main.gd
func game_over():
	gameplay_timer.stop()
	bubble_respawn_timer.stop()

	# Clean up all bubbles safely
	for bubble in active_bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	active_bubbles.clear()

	game_status_label.show()
	game_status_label.text = "Waktu Habis!\nSkor Akhir: %d" % score
	
	print("DEBUG: Showing game status label with text: ", game_status_label.text)
	print("DEBUG: Label visible: ", game_status_label.visible)
	print("DEBUG: Label position: ", game_status_label.position)

	print("DEBUG: Bubble minigame final score: ", score)
	
	# Wait 2 seconds before sending signal so player can see the score
	if is_inside_tree():
		await get_tree().create_timer(2.0).timeout
		print("DEBUG: About to send minigame_completed signal")
	
	# Send signal that minigame is completed with the score AFTER the delay
	minigame_completed.emit(score)

	# Additional wait before removing this scene (optional, but good for cleanup)
	if is_inside_tree():
		await get_tree().create_timer(0.5).timeout
		print("DEBUG: About to remove bubble minigame scene")
		# Only queue_free if still in tree
		if is_inside_tree():
			queue_free()

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
	var positives_to_add = 6 - traps_added
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
	return positions

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if gameplay_timer.is_stopped(): return
		handle_typing(event)

func handle_typing(event):
	var key_typed = OS.get_keycode_string(event.keycode).to_upper()
	if target_bubble == null:
		for bubble in active_bubbles:
			if is_instance_valid(bubble) and bubble.positive_affirmation.begins_with(key_typed):
				target_bubble = bubble
				current_typed_string = key_typed
				player_input_label.text = current_typed_string
				target_bubble.play_typing_feedback()
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
			if current_typed_string == target_bubble.positive_affirmation:
				# Check if bubble is still valid before processing
				if is_instance_valid(target_bubble):
					if target_bubble.is_in_group("trap_bubbles"):
						score -= 10
						print("DEBUG: Hit trap bubble, score now: ", score)
					else:
						score += 5
						print("DEBUG: Hit positive bubble, score now: ", score)
					score_label.text = "Skor: %d" % score
					active_bubbles.erase(target_bubble)
					target_bubble.pop()
				reset_typing()
		else:
			# If wrong key typed, just reset target
			reset_typing()

func reset_typing():
	target_bubble = null
	current_typed_string = ""
	player_input_label.text = ""
