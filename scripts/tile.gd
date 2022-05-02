extends Node
class_name Tile    

export(String) var _name 
export(int) var _terrain_type

onready var Highlight = $Highlight\

func get_name(): return _name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func highlight_on():
	Highlight.visible = true
	
func highlight_off():
	Highlight.visible = false
	
func highlight_toggle():
	Highlight.visible = !Highlight.visible
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
