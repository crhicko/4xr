extends Node
class_name GridSpaceRegion

# Effectively a subset of the map that contains a list of all tiles that inhabit the region
# Regions can be a province, a biome, an island, an ocean, a lake, a set of selected tiles
# Provides: Efficient traversals with dfs and bfs

# Want to be able to add to this region by only looking for tile neighboring this region
# Regions are defined as a group of tiles that is contiguous
# A Map must have at least one entry in it

#Each tile is aware of its own adjacency, but in order to have efficient traversals we will have a seaprate adj list in this region
#and it will be built from the initial tiles passed into it
var _adj_list = {}
var _root
var _name setget set_name, get_name
var _gs_type setget ,get_gs_type

func get_gs_type(): return _gs_type

#set this up so that we can init with just a gs or a whole dict of gs'
func _init(grid_spaces, name='Default', gs_type=TileResources.gs_types.Map):
	_gs_type = gs_type
	set_name(name)
	#if its just 1 tile when intiating lets wrap into a dic and then build the list
	if typeof(grid_spaces) == TYPE_OBJECT:
		grid_spaces = { grid_spaces:1 }
	
	_buildAdjList(grid_spaces)
	set_root();

func _buildAdjList(grid_spaces: Dictionary):
	for gs in grid_spaces.keys():
		add_grid_space(gs)
#	for gs in grid_spaces.keys():
#		if !_adj_list.has(gs):
#			_adj_list[gs] = []
#	for gs in grid_spaces.keys():
#		var neighbors = gs.getNeighbors()
#		for n in neighbors:
#			_adj_list[gs].append(n)

				
func get_all_grid_spaces():
	return _adj_list.keys()
	
func modify_terrain(rule_func: FuncRef,alter_func: FuncRef):
	pass

#	for t in tiles.values():
#	pass

	
func get_grid_spaces_with_rules(rule_func: FuncRef) -> Array:
	var gs = []
	for g in _adj_list.keys():
		if rule_func.call_func(g):
			gs.append(g)
	return gs

func add_grid_space(grid_space: GridSpace):
	assert(!_adj_list.has(grid_space))
	_adj_list[grid_space] = []
	#adjust adjacency list
	var neighbors = grid_space.getNeighbors()
	for n in neighbors:
		if _adj_list.has(n):
			_adj_list[n].append(grid_space)
			_adj_list[grid_space].append(n)

func remove_grid_space(grid_space: GridSpace):
	#remove adjacencies
	var neighbors = _adj_list[grid_space]
	for n in neighbors:
		var n_adj: Array = _adj_list[n]
		n_adj.erase(grid_space)
	#new root
	if _root == grid_space:
		set_root()
	#remove from list
	_adj_list.erase(grid_space)
	#if empty, delete
	if _adj_list.size() == 0:
		destroy()
	
func set_root(root: GridSpace = null):
	if !root:
		_root = _adj_list.keys()[0]
	else:
		_root = root

func get_random_grid_space() -> GridSpace:
	var random_index = randi() % _adj_list.size();
	return _adj_list.keys()[random_index];


#not tested
func breadth_traverse(root: GridSpace = _root) -> Array:
	var q = []
	var region = []
	var visited = {}
	q.append(root)
	while(!q.empty()):
		var gs = q.pop_front()
		if visited.has(gs):
			continue
		else:
			visited[gs] = 1
		var tile: Tile = gs.get_tile()
		var neighbors = _adj_list[gs]
		region.append(gs)
		q.append_array(neighbors)	
	return region

func depth_traverse():
	pass

func get_size():
	return _adj_list.size()
	
func destroy():
	#TODO: handle signal stuff
	self.queue_free()
	
func set_name(n):
	_name = n
func get_name():
	return(_name)
	
func set_all_tiles(tile:PackedScene):
	for t in _adj_list.keys():
		t.set_tile(tile.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
