extends Node
class_name GridSpaceRegion

# Effectively a subset of the map that contains a list of all tiles that inhabit the region
# Regions can be a province, a biome, an island, an ocean, a lake, a set of selected tiles
# Provides: Efficient traversals with dfs and bfs

# Want to be able to add to this region by only looking for tile neighboring this region
# Regions are defined as a group of tiles that is contiguous
# A Map must have at least one entry in it


#List of tiles to operate on, tiles are objects so these will be by reference (:
var _grid_spaces = {}
#Each tile is aware of its own adjacency, but in order to have efficient traversals we will have a seaprate adj list in this region
#and it will be built from the initial tiles passed into it
var _adj_list = {}
var _name

func _init(grid_spaces: Dictionary):
	_grid_spaces = grid_spaces;
	_buildAdjList(_grid_spaces);
#	print(_adj_list)

func _buildAdjList(grid_spaces: Dictionary):
	for gs in grid_spaces.keys():
		if !_adj_list.has(gs):
			_adj_list[gs] = []
	for gs in grid_spaces.keys():
		var neighbors = gs.getNeighbors()
		for n in neighbors:
			_adj_list[gs].append(n)
#			if !_adj_list.has(n):
#				_adj_list[n] = [gs]
#			else:
#				_adj_list[n].append(gs)
				
func get_all_grid_spaces():
	return _grid_spaces
	
func modify_terrain(rule_func: FuncRef,alter_func: FuncRef):
	pass
#	for t in tiles.values():
#	pass
	
func get_grid_spaces_with_rules(rule_func: FuncRef):
	var gs = []
	for g in _grid_spaces.keys():
		if rule_func.call_func(g):
			gs.append(g)
	return gs

func addTile(tile):
	pass

func removeTile(tile):
	pass

func getSize():
	return _grid_spaces.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
