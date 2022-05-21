extends Resource
class_name River

var node_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init():
	pass
	
func push_point(point: TilePoint):
	if !node_list.has(node_list):
		node_list.append(point)
		
func pop_point():
	node_list.pop_back()
	return node_list.back()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
