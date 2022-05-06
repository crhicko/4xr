extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
#traverses and returns a map containing all contiguous gs with a rule
func get_region_with_rules(root: GridSpace, parent_region: GridSpaceRegion, rule_func: FuncRef) -> Dictionary:
	var q = []
	var region = {}
	var visited = {}
	q.append(root)
	while(!q.empty()):
		var gs = q.pop_front()
		if visited.has(gs):
			continue
		else:
			visited[gs] = 1
		var tile: Tile = gs.get_tile()
		var neighbors = parent_region._adj_list[gs]
		if rule_func.call_func(gs):
			region[gs] = true
			q.append_array(neighbors)	
	return region
	
#get asubregion within the region, does not require all pieces of the region to satisfy the rule func
func get_subregion_with_rules(root: GridSpace, parent_region: GridSpaceRegion, rule_func: FuncRef) -> Dictionary:
	var q = []
	var region = {}
	var visited = {}
	q.append(root)
	while(!q.empty()):
		var gs = q.pop_front()
		if visited.has(gs):
			continue
		else:
			visited[gs] = 1
		var tile: Tile = gs.get_tile()
		var neighbors = parent_region._adj_list[gs]
		if rule_func.call_func(gs):
			region[gs] = true
		q.append_array(neighbors)	
	return region

func propagate_biome(gs_region: GridSpaceRegion, tile:Tile, amount:int = 4) -> void:
	var gs = gs_region._root
	for i in range(randi() % 5 + 2):
			var neighbors = gs_region._adj_list[gs]
			var valid_neighbors = []
			for neighbor in neighbors:
				if neighbor.get_tile()._terrain_type == TileResources.types.Empty:
					valid_neighbors.append(neighbor)
			if valid_neighbors.size() == 0:
				continue
			var rand_neighbor = valid_neighbors[randi() % valid_neighbors.size()]
			gs = rand_neighbor
			gs_region.add_grid_space(gs)
			gs.set_tile(tile.instance())
			
func place_biome_roots(gs_region: GridSpaceRegion, amount:int = 16) -> Array:
	var regions = []
	for i in range(amount):
		#pick tile
		var rand_biome: PackedScene = TileResources.scenes.values()[randi() % TileResources.scenes.size()]
		var rand_location = gs_region.get_random_grid_space()
		var inst = rand_biome.instance()
		while rand_biome.get_state().get_node_name(0) == "EmptyLandTile" || inst._terrain_type != TileResources.types.Land || \
			!is_neighbor_empty(rand_location) || rand_location.get_tile().get_name() != "EmptyLand":
			inst.queue_free()
			rand_biome = TileResources.scenes.values()[randi() % TileResources.scenes.size()]
			inst = rand_biome.instance()
			rand_location = gs_region.get_random_grid_space()
		var tile = rand_biome.instance()
		rand_location.set_tile(tile)
		var r = GridSpaceRegion.new(rand_location,tile.get_name() + " " + str(i), TileResources.gs_types.Biome)
		regions.append(r)
	return regions
		
func is_neighbor_rule(gs:GridSpace, rule_func: FuncRef) -> bool:
	return rule_func.call_func(gs)
		 
	
#funcrefs	
func is_neighbor_land(grid_space: GridSpace):
	var t = grid_space.get_tile()
	if t != null and t._terrain_type == TileResources.types.Land:
		return false
	var spaces = grid_space.getNeighbors()
	for gs in spaces:
		var tile = gs.get_tile()
		if tile != null and tile._terrain_type == TileResources.types.Land:
			return true
	return false

func is_neighbor_tile(grid_space:GridSpace, tile):
	var neighbors = grid_space.get_neighbors()
	var temp_tile = tile.instance()
	for n in neighbors:
		var t:Tile = n.get_tile()
		if t.get_name() == temp_tile.get_name():
			return true
	return false
	
func is_neighbor_empty(grid_space: GridSpace):
	var neighbors = grid_space.getNeighbors()
	for n in neighbors:
		var t:Tile = n.get_tile()
		if t.get_name() == "EmptyLand" || t.get_name() == "Coast":
			continue
		return false
	return true
	

func is_deep_ocean(grid_space: GridSpace):
	var tile = grid_space.get_tile()
	if tile._name == "Base":
		return true
	return false
	
func is_ocean(grid_space: GridSpace):
	var tile = grid_space.get_tile()
	if tile._terrain_type == TileResources.types.Water or tile._terrain_type == TileResources.types.Empty:
		return true
	return false
			
#Find the islands in a region and then create a region for each one
func create_island_regions(gs_region: GridSpaceRegion) -> Array:
	var visited = {}
	var islands = []
	var queue = []
	var count = 0;
	queue.append(gs_region._root)
	while(!queue.empty()):
		var size = queue.size()
		for i in range(size):
			var gs: GridSpace = queue.pop_front()
			if visited.has(gs):
				continue
			else:
				visited[gs] = 1
			var neighbors = gs_region._adj_list[gs]
			var tile: Tile = gs.get_tile()
			if tile._terrain_type == TileResources.types.Land:
				count += 1
				var island = get_region_with_rules(gs, gs_region, funcref(self, "is_land"))
				var gs_island = GridSpaceRegion.new(island, "Island " + str(count), TileResources.gs_types.Island)
				for t in gs_island._adj_list.keys():
					visited[t] = 1
				islands.append(gs_island)
			queue.append_array(neighbors)				
	return islands
	
func is_land(gs: GridSpace):
	var tile: Tile = gs.get_tile()
	if tile._terrain_type == TileResources.types.Land:
		return true
	else:
		return false


func get_highest_noise_spaces(amount: int, gs_region: GridSpaceRegion) -> Array:
	var spaces: Array = gs_region._adj_list.keys()
	spaces.sort_custom(self, "noise_sort")
	return spaces.slice(0,amount - 1)
	
#Returns the regions of the mountains that are placed
func place_mountain_roots(gs_region: GridSpaceRegion, amount:int = 4) -> Array:
	var roots = []
	var regions = []
	var count = 1
	var landlocked = get_subregion_with_rules(gs_region._root, gs_region, funcref(self, "is_landlocked"))
	#pick random tiles according to amount
	for n in range(amount):
		var rand = randi() % landlocked.size()
		var gs = landlocked.keys()[rand]
		while roots.has(gs) || neighbor_has_terrain(gs, "Mountain"):
			rand = randi() % landlocked.size()
			gs = landlocked.keys()[rand]
		#grow
		regions.append(GridSpaceRegion.new(gs, "Mountain Range " + str(n + 1), TileResources.gs_types.Biome))
		gs.set_tile(TileResources.scenes.mountain.instance())
		for i in range(randi() % 5 + 2):
			var neighbors = gs_region._adj_list[gs]
			var valid_neighbors = []
			for neighbor in neighbors:
				if neighbor.get_tile().get_name() != "Mountain":
					valid_neighbors.append(neighbor)
			if valid_neighbors.size() == 0:
				continue
			var rand_neighbor = valid_neighbors[randi() % valid_neighbors.size()]
			gs = rand_neighbor
			regions[n].add_grid_space(gs)
			gs.set_tile(TileResources.scenes.mountain.instance())
	return regions
	
func neighbor_has_terrain(gs: GridSpace, text: String) -> bool:
	var neighbors = gs.getNeighbors()
	for n in neighbors:
		var tile:Tile = n.get_tile()
		if text == tile.get_name():
			return true
	return false
	
func noise_sort(a: GridSpace,b: GridSpace):
	if a.get_noise() > b.get_noise():
		return true
	return false

func is_landlocked(gs: GridSpace):
	var neighbors = gs.getNeighbors()
	for n in neighbors:
		var t: Tile = n.get_tile()
		if t._terrain_type == TileResources.types.Water:
			return false
	return true
	
func set_tiles_from_array(arr,tile:PackedScene):
	for t in arr:
		t.set_tile(tile.instance())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
