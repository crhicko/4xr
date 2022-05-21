extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var points = []
var faces = []

func set_face(dir):
	faces.empty()
	faces.append(dir)
	faces.append(TileResources.get_opposite_ndirection(dir))
	return faces

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
