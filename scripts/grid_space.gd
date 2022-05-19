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

var tile_edges = {
	"ne": null,
	"nw": null,
	"e": null,
	"se": null,
	"sw": null,
	"w": null
}

var _tile: Tile setget set_tile, get_tile

onready var GridController = $"/root/Game/GridController"

var biome: Biome

var width = 69.28;
var height = 80;

var cube_directions = {
		TileResources.NDirections.SOUTHWEST: {"r": 1, "s": 0, "q": -1},
		TileResources.NDirections.SOUTHEAST: {"r": 1, "s": -1, "q": 0},
		TileResources.NDirections.WEST: {"r": 0, "s": 1, "q": -1},
		TileResources.NDirections.EAST: {"r": 0, "s": -1, "q": 1},
		TileResources.NDirections.NORTHWEST: {"r": -1, "s": 1, "q": 0},
		TileResources.NDirections.NORTHEAST: {"r": -1, "s": 0, "q": 1}
	}

signal _grid_space_clicked(gridSpace)

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
#	match dir:
#		TileResources.NDirections.NORTHEAST:
#			return GridController.getHexCube(_r + directions[5].r, _s + directions[5].s, _q + directions[5].q)
#		TileResources.NDirections.EAST:
#			return GridController.getHexCube(_r + directions[3].r, _s + directions[3].s, _q + directions[3].q)
#		TileResources.NDirections.SOUTHEAST:
#			return GridController.getHexCube(_r + directions[1].r, _s + directions[1].s, _q + directions[1].q)
#		TileResources.NDirections.SOUTHWEST:
#			return GridController.getHexCube(_r + directions[0].r, _s + directions[0].s, _q + directions[0].q)
#		TileResources.NDirections.WEST:
#			return GridController.getHexCube(_r + directions[2].r, _s + directions[2].s, _q + directions[2].q)
#		TileResources.NDirections.NORTHWEST:
#			return GridController.getHexCube(_r + directions[4].r, _s + directions[4].s, _q + directions[4].q)

func get_direction_neighbor(gs: GridSpace):
	var arr = getNeighbors()
	var index = arr.find(gs)
	if index == -1:
		return null
	else:
		return index

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
		print("here2")
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("here3")
			emit_signal("_grid_space_clicked", self)

