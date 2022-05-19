extends Node
class_name MapGenerator

var _dimensions: Vector2 setget set_dimensions, get_dimensions
func set_dimensions(d): _dimensions = d
func get_dimensions(): return _dimensions

var _world: GridSpaceRegion

var gridController
onready var TerrainLib = preload("res://scripts/terrain/TerrainManager.gd").new()

func _init(dimensions: Vector2):
	set_dimensions(dimensions)
	
func _ready():
	print("YO")
	gridController = get_parent()
	
	
# Size: The island must find into a box of this shape
# Returns: Array of gridspaceregions for the grid controller to fuck with
func generate_map(num_tiles:int = 40, method = TileResources.generation_types.Chunk, num_islands: int = 1) -> Array:
	var regions = []
	_world = GridSpaceRegion.new(generate_rect(_dimensions.x, _dimensions.y), "World")
	_world.set_all_tiles(TileResources.scenes.ocean)
	regions.append(_world)
	gridController.set_2d_map(_world)
	
	#set the edge nodes for grid spaces
	gridController.set_edge_nodes()
	
#	yield(get_tree().create_timer(1), "timeout")
	
	#raise jittered chunk of shallows
	var _shallows = GridSpaceRegion.new(generate_jittered_chunk(300), "Shallows")
	print(_shallows.get_size())
	_shallows.set_all_tiles(TileResources.scenes.coast)
	regions.append(_shallows)
	
#	yield(get_tree().create_timer(1), "timeout")
	
	var _island = GridSpaceRegion.new(generate_jittered_chunk(_shallows.get_size() * 0.9, _shallows, funcref(TerrainLib, "is_neighbor_ocean")), "Main Island")
	print(_island.get_size())
	while(_island.get_size() < 160):
		_island.destroy_and_replace_tiles(TileResources.scenes.coast)
		_island = GridSpaceRegion.new(generate_jittered_chunk(_shallows.get_size() * 0.9, _shallows, funcref(TerrainLib, "is_neighbor_ocean")), "Main Island")
		print(_island.get_size())
	_island.set_all_tiles(TileResources.scenes.emptyland)
	regions.append(_island)
	_shallows.remove_grid_spaces(_island.get_all_grid_spaces())
	for gs in _shallows.get_all_grid_spaces():
		gs.set_elevation(-0.1)
	
	generate_humidity(_island)
	generate_temperature(_island)
	generate_elevation(_island, true)
	generate_vegetation(_island)
	populate_tiles(_island)
	populate_elevation(_island)
	populate_vegetation(_island)
	for s in seed_rivers(_island):
		propagate_river(s)
	
#	var _mountains = TerrainLib.place_mountain_roots(_island)
#	for m in _mountains:
#		regions.append(m)
	
	
	return regions

#Map gen is height based
# 0 - Deep Ocean
# 1 - Coastal Ocean
# 2 - Lvl 1 lande
# 3 - Hilly terrain
# 4 - Mountain

# Step 1:
#Fill the map with Deep Ocean(0)
# Raise jittered chunks of Coastal ocean
# Raise jittered chunk of Land
# Riase micro chunks of hilly terrain
# Raise Mountains
# Raise rivers on seams
# Lower areas for lake formation

func generate_rect(width: int, height: int) -> Dictionary:
	var GridResource = preload("res://scenes/GridSpace.tscn")
	var _tiles = {}
	for i in range(width):
		for j in range(height):
			var g = GridResource.instance()
			var x
			if j % 2 == 0:
				x = i * 2
			else:
				x = i * 2 + 1
			g.createGridSpace2D(x,j)
			_tiles[g] = true
			get_parent().add_child(g)
			g.connect("_grid_space_clicked", get_parent(), "_on_grid_space_clicked")
#			_grid_map[str(x) + "," + str(j)] = g
	return _tiles	

#generate in a circle and 
func generate_jittered_chunk(size:int, parent_region: GridSpaceRegion = null, rule_func: FuncRef = null, origin: Vector2 = Vector2(_dimensions.x, _dimensions.y / 2)) -> Dictionary:
	var _tiles = {}
	var q = []
	var gs = gridController.getHex2D(int(origin.x) if int(origin.y) % 2 == 0 else origin.x + 1, origin.y)
	#In the case that the rule func is invalidating at the origin
	while rule_func && rule_func.call_func(gs):
		gs = gs.getNeighbors()[randi() % gs.getNeighbors().size()]
	q.append(gs)
	var cnt = 0
	while cnt < size && q.size() > 0:
		gs = q.pop_front()
		if _tiles.keys().has(gs) || randf() < 0.5 and cnt > 0:
			continue
		if rule_func && rule_func.call_func(gs):
			continue
		if gs._x == 0 || gs._x == 1 || gs._x == (_dimensions.x - 1) * 2 || gs._x == (_dimensions.x - 1) * 2 + 1:
			continue
		if gs._y == 0 || gs._y ==_dimensions.y - 1 :
			continue
		var neighbors = gs.getNeighbors()
		if parent_region != null:
			var valid_neighbors = []
			for n in neighbors:
				if parent_region.has(n):
					valid_neighbors.append(n)
			q.append_array(valid_neighbors)
		else:
			q.append_array(neighbors)
		_tiles[gs] = true
		cnt += 1
#		var valid_neighbors = []
#		for n in neighbors:
#			if !_tiles.keys().has(n):
#				valid_neighbors.append(n)
#		if valid_neighbors.size() == 0:
#			continue
#		var random_tile = neighbors[randi() % neighbors.size()]
#		gs = random_tile
#		if valid_neighbors.size() < 3:
			
#		_tiles[random_tile] = true
		#some funcreffy stuff + default return true
	return _tiles

func generate_temperature(gs_region: GridSpaceRegion, noise_seed = randi()):
	var NoiseLib = OpenSimplexNoise.new()
	NoiseLib.seed = noise_seed
	NoiseLib.octaves = 2
	NoiseLib.period = 8
	NoiseLib.persistence = 0.4
	for g in gs_region.get_all_grid_spaces():
		g.set_temperature(NoiseLib.get_noise_2d(g._x, g._y))

func generate_humidity(gs_region: GridSpaceRegion, noise_seed = randi()):
	var NoiseLib = OpenSimplexNoise.new()
	NoiseLib.seed = noise_seed
	NoiseLib.octaves = 4
	NoiseLib.period = 8
	NoiseLib.persistence = 0.2
	for g in gs_region.get_all_grid_spaces():
		g.set_humidity(NoiseLib.get_noise_2d(g._x, g._y))
		
func generate_elevation(gs_region: GridSpaceRegion, normalize: bool = false, noise_seed = randi() ):
	var NoiseLib = OpenSimplexNoise.new()
	NoiseLib.seed = noise_seed
	NoiseLib.octaves = 3
	NoiseLib.period = 5
	NoiseLib.persistence = 0.6
	for g in gs_region.get_all_grid_spaces():
		if !normalize:
			g.set_elevation(NoiseLib.get_noise_2d(g._x, g._y))
		else:
			g.set_elevation((NoiseLib.get_noise_2d(g._x, g._y) + 1) / 2)
		
func generate_vegetation(gs_region: GridSpaceRegion, noise_seed = randi()):
	var NoiseLib = OpenSimplexNoise.new()
	NoiseLib.seed = noise_seed
	NoiseLib.octaves = 3
	NoiseLib.period = 5
	NoiseLib.persistence = 0.6
	for g in gs_region.get_all_grid_spaces():
		g.set_vegetation(NoiseLib.get_noise_2d(g._x, g._y))
		
func populate_tiles(gs_region: GridSpaceRegion):
	for g in gs_region.get_all_grid_spaces():
		var h = g.get_humidity()
		var temp = g.get_temperature()
		if temp > 0.2:
			if h < 0:
				g.set_tile(TileResources.scenes.desert.instance())
			elif h < 0.5:
				g.set_tile(TileResources.scenes.dryrocks.instance())
			else:
				g.set_tile(TileResources.scenes.savannah.instance())
		elif temp > -0.5:
			if h < 0:
				g.set_tile(TileResources.scenes.plains.instance())
			else:
				g.set_tile(TileResources.scenes.grassland.instance())
		elif temp > -0.8:
			if h > -0.4:
				g.set_tile(TileResources.scenes.tundra.instance())
			else:
				g.set_tile(TileResources.scenes.snow.instance())
		else:
			g.set_tile(TileResources.scenes.snow.instance())

func populate_elevation(gs_region: GridSpaceRegion):
	for g in gs_region.get_all_grid_spaces():
		var e = g.get_elevation()
		if e > 0.7:
			g.set_tile(TileResources.scenes.mountain.instance())
		elif e > 0.55:
			g.get_tile().set_hill(true)
			
func populate_vegetation(gs_region: GridSpaceRegion):
	for g in gs_region.get_all_grid_spaces():
		var v = g.get_vegetation()
		if v > 0:
			g.get_tile().set_forest(true)
	
func seed_rivers(gs_region: GridSpaceRegion, amount: int = 4) -> Array:
	var river_seeds = []
	var headwater_scene = preload("res://scenes/terrain/Headwater.tscn")
	for i in range(amount):
		var gs = gs_region.get_random_grid_space()
		while !gs.get_tile()._allows_river || gs.get_elevation() < 0.3 || gs.get_tile()._features.river || \
			TerrainLib.is_neighbor_tile(gs, TileResources.scenes.coast) || TerrainLib.is_neighbor_river(gs):
			gs = gs_region.get_random_grid_space()
		var t = gs.get_tile()
		t.set_river(true)
		t.add_to_connection_point(t.connection_paths.points.N,headwater_scene)
		river_seeds.append(gs)
	return river_seeds
		
func propagate_river(gs: GridSpace):
#	var river = River.new()
	var river_tiles = []
	while gs != null && gs.get_tile().get_name() != "Coast":
		gs.get_tile().set_river(true)
		river_tiles.append(gs)
		var king_e = 1
		var king_gs = null
		for n in gs.getNeighbors():
			if river_tiles.has(n):
				continue
			if n.get_elevation() < king_e:
				king_gs = n
				king_e = n.get_elevation()
#		river.add_tile(gs, king_gs)
		gs = king_gs

		
	
#receive an island and smooth it out so it looks more icelandy
func smooth_gs_region():
	pass
	

	

