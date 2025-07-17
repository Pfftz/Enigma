extends Node
var textbox

# Called when the node enters the scene tree for the first time.
func _ready():
	textbox = load("res://scenes/control.tscn")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func create_Textbox(textboxText : PackedStringArray, parent: Node):
	var newTextbox = textbox.instantiate()
	newTextbox.get_child(0).get_child(0).textboxes = textboxText
	parent.add_child(newTextbox)
	pass
