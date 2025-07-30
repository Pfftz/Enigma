# main.gd (Versi Perbaikan untuk Balon Negatif)

extends Node2D

var BubbleScene = preload("res://scenes/core game/bubble.tscn")
var BubbleScript = preload("res://scripts/core game/bubble.gd")

var positive_words = ["BISA", "OKAY", "KUAT", "CUKUP", "MAJU", "RELAX"]
var negative_words = ["STRES", "LELAH", "GELAP", "TAKUT", "CEMAS", "KALAH"]

var active_bubbles = []
var target_bubble = null
var current_typed_string = ""

@export var max_positivity: float = 100.0
var current_positivity: float = 0.0
@export var positivity_gain: float = 25.0
@export var positivity_loss: float = 30.0

var is_special_mode = false

@onready var positivity_bar = get_node_or_null("PositivityBar")
@onready var camera = get_node_or_null("Camera2D")
@onready var player_input_label = get_node_or_null("PlayerInputLabel")


func _ready():
	positive_words.shuffle()
	negative_words.shuffle()
	spawn_initial_bubbles()
	update_positivity_bar()

func spawn_initial_bubbles():
	for bubble in active_bubbles:
		bubble.queue_free()
	active_bubbles.clear()
	for i in range(6):
		spawn_random_bubble()

func spawn_random_bubble():
	if active_bubbles.size() >= 6:
		return

	var bubble_type
	var word
	if randf() > 0.3:
		bubble_type = BubbleScript.BubbleType.POSITIVE
		word = positive_words.pick_random()
	else:
		bubble_type = BubbleScript.BubbleType.NEGATIVE
		word = negative_words.pick_random()
	
	var screen_size = get_viewport_rect().size
	var x = randf_range(screen_size.x * 0.1, screen_size.x * 0.9)
	var y = randf_range(screen_size.y * 0.1, screen_size.y * 0.9)
	create_bubble(Vector2(x, y), word, bubble_type)

func create_bubble(pos, word, type):
	var new_bubble = BubbleScene.instantiate()
	new_bubble.position = pos
	new_bubble.setup(word, type)
	add_child(new_bubble)
	active_bubbles.append(new_bubble)
	return new_bubble


# main.gd

func _input(event):
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		
		# (PERUBAHAN UTAMA) Logika untuk mode spesial
		if is_special_mode:
			# Hanya bereaksi terhadap tombol spasi
			if event.keycode == KEY_SPACE:
				if target_bubble and target_bubble.bubble_type == BubbleScript.BubbleType.SPECIAL:
					target_bubble.take_special_hit()
			
			# Hentikan proses input lain saat mode spesial aktif
			return

		var key_typed = OS.get_keycode_string(event.keycode).to_upper()

		if target_bubble == null:
			for bubble in active_bubbles:
				if bubble.positive_affirmation.begins_with(key_typed):
					target_bubble = bubble
					
					current_typed_string = key_typed
					if player_input_label:
						player_input_label.text = current_typed_string
					target_bubble.play_typing_feedback()
					return
		else:
			var potential_string = current_typed_string + key_typed
			if target_bubble.positive_affirmation.begins_with(potential_string):
				current_typed_string = potential_string
				if player_input_label:
					player_input_label.text = current_typed_string
				target_bubble.play_typing_feedback()

				if current_typed_string == target_bubble.positive_affirmation:
					if target_bubble.bubble_type == BubbleScript.BubbleType.NEGATIVE:
						trigger_negative_penalty()
					
					target_bubble.pop() 
					reset_typing()
			else:
				reset_typing()

func reset_typing():
	target_bubble = null
	current_typed_string = ""
	if player_input_label:
		player_input_label.text = ""

# (PERUBAHAN) Menambahkan case untuk BubbleType.NEGATIVE
func on_bubble_popped(bubble: Node2D):
	if not is_instance_valid(bubble):
		return
	if active_bubbles.has(bubble):
		active_bubbles.erase(bubble)

	match bubble.bubble_type:
		BubbleScript.BubbleType.POSITIVE:
			current_positivity += positivity_gain
			if current_positivity >= max_positivity:
				current_positivity = max_positivity
				trigger_special_mode()
			else:
				if not is_special_mode:
					spawn_random_bubble()
		
		# (BARU) Menangani balon negatif yang meletus.
		BubbleScript.BubbleType.NEGATIVE:
			# Penalti sudah diberikan. Cukup ganti balon dengan yang baru.
			if not is_special_mode:
				spawn_random_bubble()

		BubbleScript.BubbleType.SPECIAL:
			is_special_mode = false
			current_positivity = 0
			spawn_initial_bubbles()

	update_positivity_bar()
	bubble.queue_free()

func update_positivity_bar():
	if positivity_bar:
		positivity_bar.max_value = max_positivity
		positivity_bar.value = current_positivity

func trigger_negative_penalty():
	current_positivity -= positivity_loss
	if current_positivity < 0:
		current_positivity = 0
	update_positivity_bar()
	screen_shake(10, 0.3)

func trigger_special_mode():
	is_special_mode = true
	for bubble in active_bubbles:
		bubble.queue_free()
	active_bubbles.clear()
	var special_bubble = create_bubble(Vector2.ZERO, "SPAM!", BubbleScript.BubbleType.SPECIAL)
	target_bubble = special_bubble
	if player_input_label:
		player_input_label.text = ""

func screen_shake(amount: float, duration: float):
	if camera:
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), duration / 4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), duration / 4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), duration / 4).set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset", Vector2.ZERO, duration / 4).set_trans(Tween.TRANS_SINE)
