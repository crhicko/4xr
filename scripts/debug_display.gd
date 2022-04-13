extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("emit_debug_info", self, "display_text")
	pass # Replace with function body.

func display_text(text):
	self.visible = true
	self.text = text
	
func close_display():
	
	self.visible = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
