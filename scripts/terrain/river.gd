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
	
func propagate():
	var pt = node_list.back()
	while(!is_next_to_water() && pt.rivers.size() < 2):
		pt = calc_best_path(pt)
		if pt == null:
			return
		push_point(pt)
	
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
	
func calc_best_path(cur_point):
#	var cur_point: TilePoint = node_list.back()
	var conn_pts = {}
	var conn_temp = cur_point.connections
	var conn_occ_count = 0
	for p in range(conn_temp.size()):
		var cp = conn_temp.values()[p]
		var cp_key = conn_temp.keys()[p]
		if cp != null && !node_list.has(cp):
			conn_pts[cp_key] = cp
#			if cp.is_occupied:
#				conn_occ_count += 1
	
	if conn_pts.size() == 0:
		return null
			
	var neighbors = cur_point.gs_neighbor_directions
	var lowest_e = INF
	var lowest_e_dir = null
	for dir in conn_pts.keys():
		var e
		match dir:
			TileResources.Directions.NORTH: 
				e = (neighbors[TileResources.Directions.NORTHWEST].get_elevation() + neighbors[TileResources.Directions.NORTHEAST].get_elevation()) / 2
			TileResources.Directions.SOUTHEAST:
				e = (neighbors[TileResources.Directions.SOUTH].get_elevation() + neighbors[TileResources.Directions.NORTHEAST].get_elevation()) / 2
			TileResources.Directions.SOUTHWEST: 
				e = (neighbors[TileResources.Directions.NORTHWEST].get_elevation() + neighbors[TileResources.Directions.SOUTH].get_elevation()) / 2
			TileResources.Directions.SOUTH: 
				e = (neighbors[TileResources.Directions.SOUTHWEST].get_elevation() + neighbors[TileResources.Directions.SOUTHEAST].get_elevation()) / 2
			TileResources.Directions.NORTHWEST:
				e = (neighbors[TileResources.Directions.SOUTHWEST].get_elevation() + neighbors[TileResources.Directions.NORTH].get_elevation()) / 2
			TileResources.Directions.NORTHEAST: 
				e = (neighbors[TileResources.Directions.NORTH].get_elevation() + neighbors[TileResources.Directions.SOUTHEAST].get_elevation()) / 2
		if e < lowest_e:
			lowest_e = e
			lowest_e_dir = dir
	return conn_pts[lowest_e_dir]
	
func is_next_to_water():
	var pt: TilePoint = node_list.back()
	var neighbors = pt.gs_neighbor_directions.values()
	for n in neighbors:
		var t:Tile = n.get_tile()
		if t._terrain_type == TileResources.types.Water:
			return true
	return false
	
			
		
	
func push_point(point:Node):
	if !node_list.has(node_list):
		node_list.append(point)
		if point.has_method("set_is_occupied"):
			point.set_is_occupied(true)
			point.rivers.append(self)
		print(point.global_position)
		print(line2d.global_position)
		line2d.add_point(point.global_position - line2d.global_position)
		
func pop_point():
	var p = node_list.pop_back()
	if p.has_method("set_is_occupied"):
		p.set_is_occupied(true)
		p.rivers.remove(self)
	return node_list.back()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
