extends CanvasLayer

@onready var piece_counter_label: Label = $PieceCounter
@onready var counter_container: Control = $CounterContainer

var is_counter_visible: bool = false

func _ready():
	# Hide counter initially
	if counter_container:
		counter_container.visible = false

func update_counter():
	if piece_counter_label and SaveManager.get_data():
		var piece_count = SaveManager.get_data().player_data.piece_amount
		piece_counter_label.text = "Pieces: " + str(piece_count)

func show_counter():
	if counter_container:
		counter_container.visible = true
		is_counter_visible = true
		
		# Auto-hide after 3 seconds
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(hide_counter)

func hide_counter():
	if counter_container:
		counter_container.visible = false
		is_counter_visible = false
