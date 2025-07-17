extends Area3D
var inArea = false
@export var text = ["Text"]
# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(entered)
	body_exited.connect(exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") && inArea:
		inArea = false
		Global.create_Textbox(text, self)
	pass
	
func entered(other):
	inArea = true
	pass

func exited(other):
	inArea = false
	pass

