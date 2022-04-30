extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_coast_regions(gs_region):
	var coast_tile = TileResources.scenes.coast
	for gs in gs_region:
		gs.set_tile(coast_tile.instance())

func set_region_tiles(gs_region, tile):
	for gs in gs_region:
		gs.set_tile(tile.instance())
		
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
func create_island_regions(gs_region: GridSpaceRegion):
	var visited = {}
	var islands = []
	var queue = []
	queue.append(gs_region._grid_spaces["0,0"])
	while(!queue.empty()):
		var size = queue.size()
		for i in range(size):
			var gs: GridSpace = queue.pop_front()
			var neighbors = gs_region._adj_list[gs]
			var tile: Tile = gs.get_tile()
			if tile._terrain_type == TileResources.types.Land:
				pass
			for j in neighbors:
				if !visited.has(j):
					queue.append(j)
					visited[j] = 1
				
	return islands
	
func is_land(gs: GridSpace):
	var tile: Tile = gs.get_tile()
	if tile._terrain_type == TileResources.types.Land:
		return true
	else:
		return false

#traverses and returns a map containing all contiguous gs with a rule
func get_region_with_rules(root: GridSpace, parent_region: GridSpaceRegion, rule_func: FuncRef):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
