extends Node2D
class_name GridSpace

var _r;
var _s;
var _q;
var _x;
var _y;
var _noise setget set_noise,get_noise
func set_noise(n):
	_noise = n
func get_noise():
	return _noise
	
var _humidity setget set_humidity, get_humidity
func set_humidity(h): _humidity = h; func get_humidity(): return _humidity
var _temperature setget set_temperature, get_temperature
func set_temperature(h): _temperature = h; func get_temperature(): return _temperature
var _elevation setget set_elevation, get_elevation
func set_elevation(h): _elevation = h; func get_elevation(): return _elevation
var _vegetation setget set_vegetation, get_vegetation
func set_vegetation(h): _vegetation = h; func get_vegetation(): return _vegetation

var _tile: Tile setget set_tile, get_tile

onready var GridController = $"/root/Game/GridController"

var tile_edge_scene = preload("res://scenes/tiles/edge/TileEdge.tscn")
var tile_point_scene = preload("res://scenes/tiles/edge/TilePoint.tscn")

var biome: Biome

var width = 69.28;
var height = 80;

signal _grid_space_clicked(gridSpace)

var cube_directions = {
		TileResources.NDirections.SOUTHWEST: {"r": 1, "s": 0, "q": -1},
		TileResources.NDirections.SOUTHEAST: {"r": 1, "s": -1, "q": 0},
		TileResources.NDirections.WEST: {"r": 0, "s": 1, "q": -1},
		TileResources.NDirections.EAST: {"r": 0, "s": -1, "q": 1},
		TileResources.NDirections.NORTHWEST: {"r": -1, "s": 1, "q": 0},
		TileResources.NDirections.NORTHEAST: {"r": -1, "s": 0, "q": 1}
	}

var points = {
	TileResources.Directions.NORTH: null,
	TileResources.Directions.NORTHEAST: null,
	TileResources.Directions.SOUTHEAST: null,
	TileResources.Directions.SOUTH: null,
	TileResources.Directions.SOUTHWEST: null,
	TileResources.Directions.NORTHWEST: null
}

var edges = {
	TileResources.NDirections.NORTHEAST: null,
	TileResources.NDirections.EAST: null,
	TileResources.NDirections.SOUTHEAST: null,
	TileResources.NDirections.SOUTHWEST: null,
	TileResources.NDirections.WEST: null,
	TileResources.NDirections.NORTHWEST: null
}

func createGridSpaceCube(r: float, q: float, s: float):
	setCubeCoords(r, q, s)
	var c = coordsCubeTo2D(r, q, s)
	set2DCoords(c.x, c.y)
	position.x = sqrt(3.0) * 40 * ((r/2) + q)
	position.y = 1.5 * 40 * r
	$r_coord.text = 'r: ' + str(r);
	$q_coord.text = 'q: ' + str(q);
	$s_coord.text = 's: ' + str(s);
	print(_x)

func add_neighbor_gridspace(dir,gridspace_scene) -> GridSpace:
#	var gridspace_scene = preload("res://scenes/GridSpace.tscn")
	
	#dir to vector
	var new_x
	var new_y
	match dir:
		TileResources.NDirections.NORTHEAST:
			new_x = _x + 1
			new_y = _y - 1
		TileResources.NDirections.EAST: 
			new_x = _x + 2
			new_y = _y
		TileResources.NDirections.SOUTHEAST: 
			new_x = _x + 1
			new_y = _y + 1
		TileResources.NDirections.SOUTHWEST: 
			new_x = _x - 1
			new_y = _y + 1
		TileResources.NDirections.WEST: 
			new_x = _x + 2
			new_y = _y
		TileResources.NDirections.NORTHWEST:
			new_x = _x - 1
			new_y = _y - 1
	
	var new_gs: GridSpace = gridspace_scene.instance()
	GridController.add_child(new_gs)
	new_gs.createGridSpace2D(new_x,new_y)
	var neighbors = new_gs.get_neighbors_dir_map()
	var new_neighbor_dirs = []
	var new_neighbor_null_dirs = []
	for n_dir in neighbors.keys():
		if neighbors[n_dir] != null:
			new_neighbor_dirs.append(n_dir)
		else:
			new_neighbor_null_dirs.append(n_dir)
	for n_dir in new_neighbor_dirs:
		var n = neighbors[n_dir]
		match n_dir:
			TileResources.NDirections.NORTHEAST:
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.SOUTHWEST]
				new_gs.points[TileResources.Directions.NORTH] = n.points[TileResources.Directions.SOUTHWEST]
				new_gs.points[TileResources.Directions.NORTHEAST] = n.points[TileResources.Directions.SOUTH]
			TileResources.NDirections.EAST: 
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.WEST]
				new_gs.points[TileResources.Directions.NORTHEAST] = n.points[TileResources.Directions.NORTHWEST]
				new_gs.points[TileResources.Directions.SOUTHEAST] = n.points[TileResources.Directions.SOUTHWEST]
			TileResources.NDirections.SOUTHEAST: 
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.NORTHWEST]
				new_gs.points[TileResources.Directions.SOUTHEAST] = n.points[TileResources.Directions.NORTH]
				new_gs.points[TileResources.Directions.SOUTH] = n.points[TileResources.Directions.NORTHWEST]
			TileResources.NDirections.SOUTHWEST: 
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.NORTHEAST]
				new_gs.points[TileResources.Directions.SOUTH] = n.points[TileResources.Directions.NORTHEAST]
				new_gs.points[TileResources.Directions.SOUTHWEST] = n.points[TileResources.Directions.NORTH]
			TileResources.NDirections.WEST: 
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.EAST]
				new_gs.points[TileResources.Directions.SOUTHWEST] = n.points[TileResources.Directions.SOUTHEAST]
				new_gs.points[TileResources.Directions.NORTHWEST] = n.points[TileResources.Directions.NORTHEAST]
			TileResources.NDirections.NORTHWEST:
				new_gs.edges[n_dir] = n.edges[TileResources.NDirections.SOUTHEAST]
				new_gs.points[TileResources.Directions.NORTHWEST] = n.points[TileResources.Directions.SOUTH]
				new_gs.points[TileResources.Directions.NORTH] = n.points[TileResources.Directions.SOUTHEAST]
	for n_dir in new_neighbor_null_dirs:
		_add_points_from_edge_dir(n_dir, new_gs)
	return new_gs
	
func _add_points_from_edge_dir(n_dir, new_gs):
	var long_vec = 40*sin(deg2rad(60))
	var short_vec = 40 * sin(deg2rad(30))
	var length = 40
	var ccw
	var cw
	match n_dir:
		TileResources.NDirections.NORTHEAST:
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTH)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTHEAST)
			cw.connect_points(ccw, TileResources.Directions.NORTHWEST)
		TileResources.NDirections.EAST:
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTHEAST)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTHEAST)
			cw.connect_points(ccw, TileResources.Directions.NORTH)
		TileResources.NDirections.SOUTHEAST: 
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTHEAST)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTH)
			cw.connect_points(ccw, TileResources.Directions.NORTHEAST)
		TileResources.NDirections.SOUTHWEST: 
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTH)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTHWEST)
			cw.connect_points(ccw, TileResources.Directions.SOUTHEAST)
		TileResources.NDirections.WEST: 
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.SOUTHWEST)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTHWEST)
			cw.connect_points(ccw, TileResources.Directions.SOUTH)
		TileResources.NDirections.NORTHWEST:
			ccw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTHWEST)
			cw = new_gs._configure_point(new_gs.points,TileResources.Directions.NORTH)
			cw.connect_points(ccw, TileResources.Directions.SOUTHWEST)
	new_gs._configure_edges(ccw, cw, n_dir)
	
func _configure_point(points, dir):
	var long_vec = 40*sin(deg2rad(60))
	var short_vec = 40 * sin(deg2rad(30))
	var length = 40 
	var t = points[dir]
	if t == null:
		t = tile_point_scene.instance()
		points[dir] = t
		GridController.add_child(t)
		GridController._points.append(t)
		match dir:
			TileResources.Directions.NORTH:
				t.orientation = TileResources.POINTFACING.NORTH
				t.global_position = Vector2(global_position.x, global_position.y - length)
			TileResources.Directions.NORTHEAST:
				t.orientation = TileResources.POINTFACING.SOUTH
				t.global_position = Vector2(global_position.x + long_vec, global_position.y - short_vec)
			TileResources.Directions.SOUTHEAST:
				t.orientation = TileResources.POINTFACING.NORTH
				t.global_position = Vector2(global_position.x + long_vec, global_position.y + short_vec)
			TileResources.Directions.SOUTH:
				t.orientation = TileResources.POINTFACING.SOUTH
				t.global_position = Vector2(global_position.x, global_position.y + length)
			TileResources.Directions.SOUTHWEST:
				t.orientation = TileResources.POINTFACING.NORTH
				t.global_position = Vector2(global_position.x - long_vec, global_position.y + short_vec)
			TileResources.Directions.NORTHWEST:
				t.orientation = TileResources.POINTFACING.SOUTH
				t.global_position = Vector2(global_position.x - long_vec, global_position.y - short_vec)
	return t
	
func _configure_edges(ccw, cw, dir):
	var e = tile_edge_scene.instance()
	GridController.add_child(e)
	GridController._edges.append(e)
	var length = 20 / tan(deg2rad(30))
	var short_vec = length * sin(deg2rad(30))
	var long_vec = short_vec / tan(deg2rad(30))
	match dir:
		TileResources.NDirections.NORTHEAST:
			e.global_position = Vector2(global_position.x + short_vec, global_position.y - long_vec)
		TileResources.NDirections.EAST:
			e.global_position = Vector2(global_position.x + length, global_position.y)
		TileResources.NDirections.SOUTHEAST:
			e.global_position = Vector2(global_position.x + short_vec, global_position.y + long_vec)
		TileResources.NDirections.SOUTHWEST:
			e.global_position = Vector2(global_position.x - short_vec, global_position.y + long_vec)
		TileResources.NDirections.WEST:
			e.global_position = Vector2(global_position.x - length, global_position.y)
		TileResources.NDirections.NORTHWEST:
			e.global_position = Vector2(global_position.x - short_vec, global_position.y - long_vec)
	edges[dir] = e
	e.set_face(dir)

#doubled width
#0,0 2,0
#  1,1
func createGridSpace2D(x,y):
	set2DCoords(x,y)
	var c = coords2DToCube(x,y)
	setCubeCoords(c.r, c.q, c.s)
	position.x = x/2 * width if y % 2 == 0 else x/2 * width + width/2
	position.y = y * height  * 3/4 - (height / 2) if y % 2 ==0 else  y * height * 3/4  - (height/2)
	
func set2DCoords(x,y):
	_x = x
	_y = y
	
func setCubeCoords(r,q,s):
	_r = r
	_q = q
	_s = s
	
func coords2DToCube(x,y):
	var q = (x-y) / 2
	var r = y
	var s = -q-r
	return {'q': q, 'r': r, 's': s}
	
func coordsCubeTo2D(r,q,s):
	var x = q
	var y = (2 * r) + x
	return {'x': x, 'y': y}
	
#func cube_to_2d(r,s,q):
#	var x = 2 * q + r
#	var y = r
#	return Vector2(col, row)	
	
func get_shared_edge(neighbor:GridSpace):
	for e in edges.values():
		if e != null && neighbor.tile_edges.values().has(e):
			return e
	return null
	
func getNeighbors():
	var neighbors = [];
#	var directions = [
#		{"r": 1, "s": 0, "q": -1},
#		{"r": 1, "s": -1, "q": 0},
#		{"r": 0, "s": 1, "q": -1},
#		{"r": 0, "s": -1, "q": 1},
#		{"r": -1, "s": 1, "q": 0},
#		{"r": -1, "s": 0, "q": 1}
#	]
	var gc = get_parent();
	for i in range(cube_directions.size()):
		var mods = cube_directions[i]
		var t = GridController.getHexCube(_r + mods.r, _s + mods.s, _q + mods.q)
		if t:
			neighbors.append(t)
	return neighbors;
	
func get_neighbor_direction(dir):
	return GridController.getHexCube(_r + cube_directions.dir.r, _s + cube_directions.dir.s, _q + cube_directions.dir.q)

func get_direction_neighbor(gs: GridSpace):
	var arr = getNeighbors()
	var index = arr.find(gs)
	if index == -1:
		return null
	else:
		return index

func get_neighbors_dir_map():
	var neighbor_map = {
				TileResources.NDirections.NORTHWEST: GridController.get_hex_2d(_x - 1, _y - 1),
				TileResources.NDirections.NORTHEAST: GridController.get_hex_2d(_x + 1, _y - 1),
				TileResources.NDirections.EAST: GridController.get_hex_2d(_x + 2, _y),
				TileResources.NDirections.SOUTHEAST: GridController.get_hex_2d(_x + 1, _y + 1),
				TileResources.NDirections.SOUTHWEST: GridController.get_hex_2d(_x - 1, _y + 1),
				TileResources.NDirections.WEST: GridController.get_hex_2d(_x - 2, _y),
			}
	return neighbor_map
	
func get_edge(dir):
	return edges[dir]
	
func get_point(dir):
	return points[dir]

func getCoords():
	return [_r, _s, _q]
	
func set_tile(tile: Tile):
	if is_instance_valid(_tile):
		_tile.queue_free()
	_tile = tile
	self.add_child(tile)

func get_tile():
	return _tile
	
func setColor():
	$Polygon2D.color = Color.brown
	return
	
func setBiome(_biome: Biome) -> void:
	biome = _biome;
	$Polygon2D.color = biome.color;
	return
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_HitBox_mouse_entered():
	SignalManager.emit_signal("emit_debug_info", 
		'x: ' +  str(_x) + '\n' +
		'y: ' +  str(_y) + '\n' +
		'r: ' +  str(_r) + '\n' +
		'q: ' +  str(_q) + '\n' +
		's: ' +  str(_s) + '\n' +
		'tile:' + str(_tile) + '\n' + 
		"global pos:" + str(global_position)
	)


func _on_HitBox_mouse_exited():
	SignalManager.emit_signal("close_debug_info")


func _on_HitBox_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("_grid_space_clicked", self)

