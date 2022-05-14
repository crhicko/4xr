extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var river_nodes = {
	"n": Vector2(0,0),
	"ne": Vector2(30,23),
	"se": Vector2(30,57),
	"s": Vector2(0,75),
	"sw": Vector2(-30, 57),
	"nw": Vector2(-3,23)
}

var drawn_nodes = []

#func connect_nodes(start, end):
#	var riv_nodes_arr = river_nodes.values()
#	var start_index = 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
