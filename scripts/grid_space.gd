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

var _tile: Tile setget set_tile, get_tile

var biome: Biome

var width = 69.28;
var height = 80;

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
	var directions = [
		{"r": 1, "s": 0, "q": -1},
		{"r": 1, "s": -1, "q": 0},
		{"r": 0, "s": 1, "q": -1},
		{"r": 0, "s": -1, "q": 1},
		{"r": -1, "s": 1, "q": 0},
		{"r": -1, "s": 0, "q": 1}
	]
	var gc = get_parent();
	for i in range(directions.size()):
		var mods = directions[i]
		var t = gc.getHexCube(_r + mods.r, _s + mods.s, _q + mods.q)
		if t:
			neighbors.append(t)
	return neighbors;

func getCoords():
	return [_r, _s, _q]
	
func set_tile(tile: Tile):
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
		'tile:' + str(_tile)
	)


func _on_HitBox_mouse_exited():
	SignalManager.emit_signal("close_debug_info")


func _on_HitBox_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		print("here2")
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("here3")
			emit_signal("_grid_space_clicked", self)

