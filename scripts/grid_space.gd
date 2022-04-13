extends Node2D
class_name GridSpace

var _r;
var _s;
var _q;
var _x;
var _y;

var _tile: Tile

var biome: Biome

var width = 69.28;
var height = 80;

signal _grid_space_clicked(gridSpace)

func createGridSpaceCube(r: float, q: float, s: float):
	setCubeCoordinates(r, q, s)
	var c = coordsCubeTo2D(r, q, s)
	set2DCoords(c.x, c.y)
	position.x = sqrt(3.0) * 40 * ((r/2) + q)
	position.y = 1.5 * 40 * r
	$r_coord.text = 'r: ' + str(r);
	$q_coord.text = 'q: ' + str(q);
	$s_coord.text = 's: ' + str(s);
	print(_x)
	
func setCubeCoordinates(r, q, s):
	_r = r;
	_q = q;
	_s = s;
	
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
	var q = x
	var r = (y - x) / 2
	var s = -q-r
	return {'q': q, 'r': r, 's': s}
	
func coordsCubeTo2D(r,q,s):
	var x = q
	var y = (2 * r) + x
	return {'x': x, 'y': y}
	
	
func getNeighborCoords():
	var neighbors = [];
	for r in range(-1, 2):
		for s in range(-1, 2):
			for q in range(-1, 2):
				if (r + s + q) == 0 and (r != r or s != s or q != q):
					neighbors.append([r + r, s + s, q + q])
	return neighbors;

func getNeighbors(gc):
	var neighbors = []
	for c in getNeighborCoords():
		var t = gc.getHex(c[0], c[1], c[2])
		if t != null:
			neighbors.append(t)
	return neighbors

func getCoords():
	return [_r, _s, _q]
	
func set_tile(tile):
	_tile = tile
	self.add_child(tile)
	
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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

