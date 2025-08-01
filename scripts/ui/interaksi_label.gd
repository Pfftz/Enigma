extends CanvasLayer
@onready var label = $InteractLabel

func show_interact_text(text: String):
	label.text = text
	label.visible = true

func hide_interact_text():
	label.visible = false
	
func _ready():
	add_to_group("ui")
