# bubble.gd

extends Node2D

# (BARU) Enum untuk mendefinisikan tipe gelembung.
enum BubbleType { POSITIVE, NEGATIVE, SPECIAL }

@export var typing_sounds: Array[AudioStream]

# (BARU) Variabel untuk menyimpan tipe dan status gelembung.
var bubble_type: BubbleType
var positive_affirmation: String
var special_health: int = 30 # Jumlah ketukan untuk meletuskan gelembung spesial.

var initial_y_position: float
var time: float = 0.0
var float_speed: float = 0.5
var float_amplitude: float = 10.0

func _ready():
	initial_y_position = position.y
	time = randf() * 10.0

func _process(delta):
	# Jangan mengambang jika ini gelembung spesial (biasanya diam di tengah).
	if bubble_type != BubbleType.SPECIAL:
		time += delta
		position.y = initial_y_position + sin(time * float_speed) * float_amplitude

# (MODIFIKASI) Setup sekarang menerima tipe gelembung.
func setup(word: String, type: BubbleType):
	positive_affirmation = word
	bubble_type = type
	$TypingLabel.text = positive_affirmation

	# (BARU) Ubah warna berdasarkan tipe untuk membedakan.
	match bubble_type:
		BubbleType.POSITIVE:
			$Sprite2D.modulate = Color(0.7, 0.9, 1) # Biru muda (default)
		BubbleType.NEGATIVE:
			$Sprite2D.modulate = Color(1, 0.6, 0.6) # Merah muda
		BubbleType.SPECIAL:
			$Sprite2D.modulate = Color(1, 0.9, 0.5) # Emas
			
			# (PERBAIKAN) Untuk pemusatan yang lebih akurat
			var sprite_size = $Sprite2D.texture.get_size()
			position = get_viewport_rect().size / 2 - (sprite_size / 2) * scale
			
			scale = Vector2(1.5, 1.5) # Buat lebih besar

func play_typing_feedback():
	if not $Sprite2D.visible:
		return
	$AnimationPlayer.play("squish")
	if not typing_sounds.is_empty():
		$AudioStreamPlayer2D.stream = typing_sounds.pick_random()
		$AudioStreamPlayer2D.play()

# (BARU) Fungsi yang dipanggil saat gelembung spesial diketuk.
func take_special_hit():
	special_health -= 1
	play_typing_feedback() # Mainkan animasi squish setiap kali diketuk
	
	# Perbarui label untuk menunjukkan sisa health
	$TypingLabel.text = str(special_health)

	if special_health <= 0:
		pop() # Meletus jika health habis
		
func pop():
	# Sembunyikan semua elemen visual.
	$Sprite2D.hide()
	$TypingLabel.hide()

	# Mainkan efek partikel... (logika ini tetap sama)
	var particles_instance = $GPUParticles2D.duplicate()
	get_parent().add_child(particles_instance)
	particles_instance.global_position = global_position
	particles_instance.emitting = true
	var particle_timer = Timer.new()
	particle_timer.wait_time = particles_instance.lifetime
	particle_timer.one_shot = true
	particle_timer.timeout.connect(particles_instance.queue_free)
	particles_instance.add_child(particle_timer)
	particle_timer.start()

	# (PENTING) Gelembung akan dihapus oleh main.gd sekarang, bukan respawn sendiri.
	# Ini untuk kontrol yang lebih baik. Kita biarkan timer dihilangkan.
	# Hapus baris get_tree().create_timer dan func _reset_bubble()
	
	# Memberi sinyal ke parent (main.gd) bahwa ia sudah meletus.
	get_parent().on_bubble_popped(self)
