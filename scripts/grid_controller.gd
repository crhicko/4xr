extends Node

export var MAX_ROWS = 26
export var MAX_COLS = 40
export var MAX_BIOMES = 5
export var RADIUS = 14

var _grid_spaces = []

#generic hash map to hold all of the tiles with "x,y" as the valid strings
var _grid_map = {
	
}

var _points = []
var _edges = []

var _island_roots = []

var _grid_space_region = {}
var _regions = {}

const GridResource = preload("res://scenes/GridSpace.tscn")
onready var TerrainLib = preload("res://scripts/terrain/TerrainManager.gd").new()
onready var mg = preload("res://scripts/terrain/map_generator.gd")

signal generate_map

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize();
	

func generate_grid():
	if _regions.size() != 0:
		for r in _regions.keys():
			_regions[r].queue_free()
			remove_region(r)
	var MapGenerator = mg.new(Vector2(3,3))
	self.add_child(MapGenerator)
	var regs = MapGenerator.generate_map()
	for r in regs:
		add_region(r, r.get_name())
		


#want to get this to just generate ourselves a nice rectangular map that we can scroll around and put tiles on
func generate_grid2():
	var time = OS.get_ticks_msec();

	_grid_space_region = GridSpaceRegion.new(genRect(MAX_COLS,MAX_ROWS), "World")
	add_region(_grid_space_region, "World")


	_regions["World"].set_all_tiles(TileResources.scenes.base)

	gen_island(MAX_COLS,MAX_ROWS)
	
	yield(get_tree().create_timer(1), "timeout")
	
	set_map_edge_biome()
	#coast settting
	var coast_spaces = _grid_space_region.get_grid_spaces_with_rules(funcref(TerrainLib,"is_neighbor_land"))
	TerrainLib.set_tiles_from_array(coast_spaces, TileResources.scenes.coast)
	#pause for gif
	yield(get_tree().create_timer(1), "timeout")
	
	var island_count = 0 
	for island_region in TerrainLib.create_island_regions(_grid_space_region):
		island_count += 1
		add_region(island_region, island_region.get_name())
	#
	add_region(GridSpaceRegion.new(TerrainLib.get_region_with_rules(_grid_space_region._adj_list.keys()[0],_grid_space_region, funcref(TerrainLib, "is_ocean"))), "Ocean")
	var deep_ocean = _regions["Ocean"].get_grid_spaces_with_rules(funcref(TerrainLib, "is_deep_ocean"))
	TerrainLib.set_tiles_from_array(deep_ocean, TileResources.scenes.ocean)
	
	var biggest_island = _get_biggest_island()
	var mountain_regions = TerrainLib.place_mountain_roots(biggest_island)
	for r in mountain_regions:
		add_region(r, r.get_name())
	#
	var biome_roots = TerrainLib.place_biome_roots(biggest_island)
	for b in biome_roots:
		add_region(b, b.get_name())
	
func _get_biggest_island():
	var island = null
	var size = 0
	for r in _regions.values():
		if r.get_gs_type() == TileResources.gs_types.Island:
			if r._adj_list.size() > size:
				size = r._adj_list.size()
				island = r
	return island
		
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

func add_region(grid_space_region, name: String):
	grid_space_region.set_name(name)
	_regions[name] = grid_space_region
	SignalManager.emit_signal("region_created",grid_space_region)
	
func remove_region(name):
	_regions.erase(name)
	SignalManager.emit_signal("region_removed", name)
	
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
		
func set_edge_nodes() -> void:
	var edge_node_scene = preload("res://scenes/tiles/edge/TileEdge.tscn")
	for row in range(MAX_ROWS):
		for col in range(MAX_COLS):
			#left, top
			var gs: GridSpace = get_hex_2d(col * 2 if row % 2 == 0 else col * 2 + 1, row)
			var neighbor_map = {
				"nw": get_hex_2d(col - 1, row - 1),
				"ne": get_hex_2d(col + 1, row - 1),
				"e": get_hex_2d(col + 2, row),
				"se": get_hex_2d(col + 1, row + 1),
				"sw": get_hex_2d(col - 1, row + 1),
				"w": get_hex_2d(col - 2, row),
			}
			var hyp = sqrt((40 * 40) - (20 * 20))
			var long_vec = hyp*sin(deg2rad(60))
			var short_vec = hyp * sin(deg2rad(30))
			for i in range(6):
				var k = neighbor_map.keys()[i]
				var n_gs = neighbor_map.values()[i]
				#already done on preivous pass
				if gs.tile_edges[k] != null:
					continue
				var e = edge_node_scene.instance()
				self.add_child(e)
				var opp = ""
				match k:
					"nw":
						e.global_position.x = gs.global_position.x - short_vec
						e.global_position.y = gs.global_position.y - long_vec
						opp = "se"
					"ne":
						e.global_position.x = gs.global_position.x + short_vec
						e.global_position.y = gs.global_position.y - long_vec
						opp = "sw"
					"e":
						e.global_position.x = gs.global_position.x + hyp
						e.global_position.y = gs.global_position.y
						opp = "w"
					"se":
						e.global_position.x = gs.global_position.x + short_vec
						e.global_position.y = gs.global_position.y + long_vec
						opp = "nw"
					"sw":
						e.global_position.x = gs.global_position.x - short_vec
						e.global_position.y = gs.global_position.y + long_vec
						opp = "ne"
					"w":
						e.global_position.x = gs.global_position.x - hyp
						e.global_position.y = gs.global_position.y
						opp = "e"
#				e.global_position.x -= 34.64
#				e.global_position.y -= -20
				
				gs.tile_edges[k] = e
				if n_gs != null:
					n_gs.tile_edges[opp] = e
#				print("adding edge")
#
#func set_point_nodes() -> void:
#	var point_node_scene = preload("res://scenes/tiles/edge/TilePoint.tscn")
#	for row in range(MAX_ROWS):
#		for col in range(MAX_COLS):
#			#left, top
#			var gs: GridSpace = get_hex_2d(col * 2 if row % 2 == 0 else col * 2 + 1, row)
#			var neighbor_map = {
#				"nw": get_hex_2d(col - 1, row - 1),
#				"ne": get_hex_2d(col + 1, row - 1),
#				"e": get_hex_2d(col + 2, row),
#				"se": get_hex_2d(col + 1, row + 1),
#				"sw": get_hex_2d(col - 1, row + 1),
#				"w": get_hex_2d(col - 2, row),
#			}
#			var hyp = 40
#			var long_vec = hyp*sin(deg2rad(60))
#			var short_vec = hyp * sin(deg2rad(30))
			#north
			
					

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
func genRect(width: int, height: int) -> Dictionary:
	var _tiles = {}
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
			_tiles[g] = true
			self.add_child(g)
			g.connect("_grid_space_clicked", self, "_on_grid_space_clicked")
			_grid_map[str(x) + "," + str(j)] = g
			cnt += 1
	print(cnt)
	return _tiles		
			
	
					
func getHexCube(r, s, q):
	var conversion = cube_to_2d(r, s, q)
	return getHex2D(conversion.x, conversion.y)

func getHex2D(x,y):
	if(_grid_map.has(str(x) + "," + str(y))):
		return _grid_map[str(x) + "," + str(y)]
	else:
		return null
		
func get_hex_2d(x,y):
	if(_grid_map.has(str(x) + "," + str(y))):
		return _grid_map[str(x) + "," + str(y)]
	else:
		return null


func set_2d_map(gs_region: GridSpaceRegion):
	for gs in gs_region._adj_list.keys():
		_grid_map[str(gs._x) + "," + str(gs._y)] = gs

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

func toggle_points_visible():
	for p in _points:
		p.visible = !p.visible
		
func toggle_edges_visible():
	for e in _edges:
		e.visible = !e.visible

func _on_PlaceRiverButton_pressed():
	for p in _points:
		p.CollisionBox.disabled = false
		
	pass # Replace with function body.


func _on_ToggleGrid_pressed():
	toggle_points_visible()
	toggle_edges_visible()
