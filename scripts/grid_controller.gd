extends Node

export var MAX_ROWS = 10
export var MAX_COLS = 10
export var MAX_BIOMES = 5
export var RADIUS = 14

var _grid_spaces = []
enum Biomes {
	DESERT,
	GRASSLAND,
	PLAINS,
	JUNGLE,
	MARSH
}
var biomeRes = [preload("res://resources/DesertBiome.tres"), 
	preload("res://resources/GrasslandBiome.tres"),
	preload("res://resources/PlainsBiome.tres"),
	preload("res://resources/JungleBiome.tres"),
	preload("res://resources/MarshBiome.tres")]

var GridResource = preload("res://scenes/GridSpace.tscn")

signal generate_map

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
#	tiles = genSpiral(RADIUS)
#	placeBiomeRoots(tiles , MAX_BIOMES)
#	var tile: GridSpace = getHex(-4,4,0)
#	print(tile.getCoords())
#	var neighborCoords = tile.getNeighborCoords()
#	print(neighborCoords)
#	var neighbors = []
#	for c in neighborCoords:
#		var t = getHex(c[0], c[1], c[2])
#		if t != null:
#			neighbors.append(t)
#	for n in neighbors:
#		print(n.getCoords())



#want to get this to just generate ourselves a nice rectangular map that we can scroll around and put tiles on
func generate_grid():
	var time = OS.get_ticks_msec();
	_grid_spaces = genRect(20,20)
#	_grid_spaces = genSpiral(RADIUS)
	print(OS.get_ticks_msec() - time)
#	placeBiomeRoots(_grid_spaces, MAX_BIOMES)
	print(OS.get_ticks_msec() - time)
	print(_grid_spaces.size())
	

		
func placeBiomeRoots(map: Array, num: int) -> void: 
	var biomeRoots = []
	for i in range(num):
		var hex = null
		var _neighbors = []
		hex = getRandomHex();
		_neighbors = hex.getNeighbors(self);
		while (biomeRoots.has(hex) or getCollisions(_neighbors,biomeRoots).size() != 0):
			randomize()
			hex = getRandomHex();
			_neighbors = hex.getNeighbors(self);
		hex.setBiome(biomeRes[i]);
		biomeRoots.append(hex)

func getRandomHex():
	var randR = randi() % (RADIUS * 2) - RADIUS;
	var arange = RADIUS * 2 - abs(randR)
	var offset = RADIUS - abs(randR)
#	print("Range: " + str(arange) + " Offset: " + str(offset))
	var randS;
	if randR > 0:
		randS = randi() % (RADIUS * 2 - abs(randR)) - RADIUS;
	else:
#		print(abs(randR) - RADIUS)
		randS = randi() % (RADIUS * 2 - abs(randR)) - abs(abs(randR) - RADIUS);
	 #if randR < 0 else
	var randQ = -(randR + randS);
#	print([randR, randS, randQ]);
	var hex = getHex(randR, randS, randQ)
	return hex
		
func genSpiral(mapSize: int, maxX = INF, maxY = INF) -> Array:
	var _tiles = []
	var cnt = 0;
	for i in range(-mapSize, mapSize + 1):
		for j in range(-mapSize, mapSize + 1):
			for k in range(-mapSize, mapSize + 1):
				if (i + j + k) == 0 and abs(i) <= maxY/2:
					var g = GridResource.instance()
					g.createGridSpaceCube(i,k,j)
					_tiles.append(g)
					self.add_child(g)
					g.connect("_grid_space_clicked", self, "_on_grid_space_clicked")
					cnt += 1;
	return _tiles;
	
##doubled coords
# 0,0   2,0
#    1,1
func genRect(width: int, height: int) -> Array:
	var _tiles = []
	var cnt = 0
	for i in range(width):
		for j in range(height):
			var g = GridResource.instance()
			if j % 2 == 0:
				g.createGridSpace2D(i * 2,j)
			else:
				g.createGridSpace2D(i * 2 + 1,j)
			_tiles.append(g)
			self.add_child(g)
			g.connect("_grid_space_clicked", self, "_on_grid_space_clicked")
			cnt += 1
	print(cnt)
	return _tiles		
			
	
					
func getHex(_r, _s, _q):
	for t in _grid_spaces:
		if t.r== _r and t.s ==_s and t.q==_q:
			return t
	return null
	
func getCollisions(arr1, arr2) -> Array:
	var coll = [];
	for i in arr1:
		if arr2.has(i):
			coll.append(i)
	return coll;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_grid_space_clicked(gridSpace):
	print("gc detected grid click signal")
	SignalManager.emit_signal("grid_space_clicked", gridSpace)

func _on_GenerateButton_button_up():
	generate_grid()
