extends RichTextLabel
@export var textboxes = ["Test", "Test 2"]
var curText = 0
var timer
var continueSfx
var closeSfx

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = $Timer
	continueSfx = $Continue
	closeSfx = get_parent().get_parent().get_node("Close")
	timer.timeout.connect(timeout)
	visible_characters = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = textboxes[curText]
	if Input.is_action_just_pressed("ui_accept"):
		if curText < textboxes.size() - 1:
			continueSfx.play()
			curText += 1
			visible_characters = 0
		else:
			closeSfx.play()
			get_parent().visible = false
			await closeSfx.finished
			get_parent().get_parent().queue_free()
	pass
	
func timeout():
	if (visible_characters < text.length()):
		visible_characters += 1
	timer.start()
	pass
	

