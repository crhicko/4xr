extends Line2D
class_name River

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _nodes = []
var _tiles = []
var _name
var _root
var line: Line2D

func _init():
	pass

#func set_root(gs: GridSpace):
#	_root = gs
#	if _nodes.size() == 1:
#		_nodes[0] = gs
#	elif _nodes.size() > 1:
#		_nodes
#	else:
#		add_tile(gs)

	
func add_tile(gs, next_gs):
	_tiles.append(gs)
	var dir = gs.get_direction_neighbor(next_gs)
	var tile: Tile = gs.get_tile()
	var neighbor_tile = next_gs.get_tile()
	
	# get the 2 possible end nodes on our current tile
	var end_nodes = tile.get_river_nodes(dir)
	# get the end node on the previous tile
	var prev_node = _nodes.back()
	# get the node dir that connects to it across the seam
	var connection_node_dirs = prev_node.get_connection_neighbor_dirs()
	# get the start node
	
	
	var cw_path = _nodes.back()
	var ccw_path
	pass
	
func replace_tile(gs):
	pass

func remove_tile(gs):
	pass

func calc_node_path():
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
