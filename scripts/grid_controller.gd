extends Node

export var MAX_ROWS = 20
export var MAX_COLS = 20
export var MAX_BIOMES = 5
export var RADIUS = 14

var _grid_spaces = []

#generic hash map to hold all of the tiles with "x,y" as the valid strings
var _grid_map = {
	
}

var _island_roots = []

var _grid_space_region = {}
var _regions = {}

enum Biomes {
	DESERT,
	GRASSLAND,
	PLAINS,
	JUNGLE,
	MARSH
}

const GridResource = preload("res://scenes/GridSpace.tscn")
onready var TerrainLib = preload("res://scripts/terrain/TerrainManager.gd").new()

signal generate_map

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();

#want to get this to just generate ourselves a nice rectangular map that we can scroll around and put tiles on
func generate_grid():
	var time = OS.get_ticks_msec();
	_grid_spaces = genRect(MAX_COLS,MAX_ROWS)
		
	#Convert the x,y map to a set of tiles as the keys
	#i wish godot had sets
	var temp = {}
	for i in _grid_map.values():
		temp[i] = 1
	_grid_space_region = GridSpaceRegion.new(temp)
	#set base tile for all of the grid spaces
	TerrainLib.set_region_tiles(_grid_space_region._adj_list.keys(), TileResources.scenes.base)	
	#generate land masses
	gen_island(MAX_COLS,MAX_ROWS)
	
	yield(get_tree().create_timer(1), "timeout")
	
	set_map_edge_biome()
	#coast settting
	var coast_spaces = _grid_space_region.get_grid_spaces_with_rules(funcref(TerrainLib,"is_neighbor_land"))
	TerrainLib.set_region_tiles(coast_spaces, TileResources.scenes.coast)
	#pause for gif
	yield(get_tree().create_timer(1), "timeout")
	#
	_regions["ocean"] = GridSpaceRegion.new(TerrainLib.get_region_with_rules(_grid_space_region._adj_list.keys()[0],_grid_space_region, funcref(TerrainLib, "is_ocean")))
#	_regions["ocean"] = GridSpaceRegion.new(TerrainLib.create_ocean_region(_grid_space_region))
	var deep_ocean = _regions["ocean"].get_grid_spaces_with_rules(funcref(TerrainLib, "is_deep_ocean"))
	TerrainLib.set_region_tiles(deep_ocean, TileResources.scenes.ocean)
	#get all islands
	
	
		
func placeBiomeRoots(map: Array, num: int) -> void: 
	var biomeRoots = []
	for i in range(num):
		var hex: GridSpace = null
		var _neighbors = []
		hex = getRandomHex();
		_neighbors = hex.getNeighbors();
		while (biomeRoots.has(hex) or getCollisions(_neighbors,biomeRoots).size() != 0):
			randomize()
			hex = getRandomHex();
			_neighbors = hex.getNeighbors();
		hex.set_tile(TileResources.scenes.base.instance())
		biomeRoots.append(hex)
		
func set_map_edge_biome() -> void:
	var t = TileResources.scenes.ocean
	for i in range(MAX_COLS):
		var grid_space = getHex2D(i * 2, 0)
		grid_space._tile = t.instance()
		var x
		if MAX_ROWS - 1 % 2 == 0:
			x = i * 2
		else:
			x = i * 2 + 1
		grid_space = getHex2D(x, MAX_ROWS - 1)
		grid_space._tile = t.instance()
	for i in range(MAX_ROWS):
		var x = 0 if i % 2 == 0 else 1
		var grid_space_left = getHex2D(x, i)
		var grid_space_right = getHex2D(x + ((MAX_COLS - 1) * 2), i)
		grid_space_left._tile = t.instance()
		grid_space_right._tile = t.instance()
		
func getRandomHex():
	var y = randi() % (MAX_ROWS)
	var x = randi() % (MAX_COLS) * 2
	if y % 2 != 0:
		if x == 0:
			x += 1
		else:
			x -= 1
	print(str(x) + "  "  + str(y))
	return getHex2D(x,y)

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
			var x
			if j % 2 == 0:
				x = i * 2
#				g.createGridSpace2D(i * 2,j)
			else:
				x = i * 2 + 1
#				g.createGridSpace2D(i * 2 + 1,j)
				
			g.createGridSpace2D(x,j)
			_tiles.append(g)
			self.add_child(g)
			g.connect("_grid_space_clicked", self, "_on_grid_space_clicked")
			cnt += 1
			_grid_map[str(x) + "," + str(j)] = g
	print(cnt)
	return _tiles		
			
	
					
func getHexCube(r, s, q):
	var conversion = cube_to_2d(r, s, q)
	return getHex2D(conversion.x, conversion.y)

func getHex2D(x,y):
	#TODO: change _grid_spaces to use a map instead
	if(_grid_map.has(str(x) + "," + str(y))):
		return _grid_map[str(x) + "," + str(y)]
	else:
		return null
#	for t in _grid_spaces:
#		if t._x == x and t._y == y:
#			return t
#	return null


func cube_to_2d(r,s,q):
	var col = 2 * q + r
	var row = r
	return Vector2(col, row)	
	
	
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
	
func gen_noise(cols, rows):
	var NoiseLib = OpenSimplexNoise.new()
	NoiseLib.seed = randi()
	NoiseLib.octaves = 3
	NoiseLib.period = 4
	NoiseLib.persistence = 0.9

	var noise = []
	for row in range(rows):
		var r = []
		for col in range(cols):
			r.append(NoiseLib.get_noise_2d(row, col))
#			print(r[col])
		noise.append(r)
	return noise

func gen_center_mask(cols, rows):
	var center_y = rows/2;
	var center_x = cols/2;
	var mask = []
	for row in range(rows):
		var r = []
		for col in range(cols):
			var d_x = (center_x - col) * (center_x - col);
			var d_y = (center_y - row) * (center_y - row);
			var dist = sqrt(d_x + d_y);
			r.append(dist / cols)
		mask.append(r)
	return mask
	
func gen_island(cols, rows):
	var noise = gen_noise(cols,rows)
	var mask = gen_center_mask(cols,rows)
	var diff = []
	for i in range(rows):
		var r = []
		for j in range(cols):
			r.append(noise[i][j] - mask[i][j])
#			print(r[j])
		diff.append(r)
		
	for i in range(rows):
		for j in range(cols):
#			print(diff[i][j])
			var x = j * 2 if i % 2 == 0 else j * 2 + 1
			var grid_space = getHex2D(x,i)
			grid_space.set_noise(diff[i][j])
			if diff[i][j] > -0.35:
#				if grid_space._tile is TileResources.scenes.base:
				grid_space._tile = TileResources.scenes.emptyland.instance()
