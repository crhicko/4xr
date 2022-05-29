extends Resource
class_name River

var node_list = []
var headwater = null
var headwater_tile: Tile = null
var line2d: Line2D

var headwater_scene = preload("res://scenes/terrain/Headwater.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(tile: Tile):
	headwater_tile = tile
	var hw = headwater_scene.instance()
	tile.add_item_to_point(hw, determine_headwater_position())
	line2d = hw.get_node("RiverLine")
	set_headwater(hw)
	
##TODO: cleanup this node on deletion
	
# sets the headwater on the tile
func set_headwater(h):
	headwater = h
	node_list.append(h)
	var first_point = determine_node_from_headwater(headwater)
	push_point(first_point)
	first_point.is_occupied = true
	
func determine_headwater_position(tile = headwater_tile):
	var gs: GridSpace = tile.get_parent()
	var neighbors = gs.get_neighbors_dir_map()
	var point_elev: Dictionary = TileResources.create_direction_dict()
	for n in range(neighbors.size()):
		var prev_n = neighbors.values()[n - 1]
		var cur_n = neighbors.values()[n]
		var prev_n_elev = prev_n.get_elevation()
		var cur_n_elev = cur_n.get_elevation()
		point_elev[n] = (cur_n_elev + prev_n_elev) / 2
	var min_dir = point_elev.values().find(point_elev.values().min())
	return min_dir	
	
func determine_node_from_headwater(h):
	var tile = h.get_parent()
	var gs = tile.get_parent()
	var dir = tile.get_item_dir(h)
	var point: TilePoint = gs.get_point(dir)
	return point
	
func push_point(point:Node):
	if !node_list.has(node_list):
		node_list.append(point)
		if point.has_method("set_is_occupied"):
			point.set_is_occupied(true)
		print(point.global_position)
		print(line2d.global_position)
		line2d.add_point(point.global_position - line2d.global_position)
		
func pop_point():
	var p = node_list.pop_back()
	if p.has_method("set_is_occupied"):
		p.set_is_occupied(true)
	return node_list.back()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
