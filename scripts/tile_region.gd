extends Node
class_name TileRegion

# Want to be able to add to this region by only looking for tile neighboring this region
# Regions are defined as a group of tiles that is contiguous
# A Map must have at least one entry in it


#List of tiles to operate on, tiles are objects so these will be by reference (:
var _tiles = []
#Each tile is aware of its own adjacency, but in order to have efficient traversals we will have a seaprate adj list in this region
#and it will be built from the initial tiles passed into it
var _adj_list = {}
var _name

func _init(tiles: Array):
	_tiles = tiles;
	_buildAdjList(_tiles);
	print(_adj_list)

func _buildAdjList(tiles):
	for tile in tiles:
		if !_adj_list.has(tile):
			_adj_list[tile] = []
		var neighbors = tile.getAllNeighbors()
		for n in neighbors:
			if !tiles.has(n):
				continue
			_adj_list[tile].append(n)
			if !_adj_list.has(n):
				_adj_list[n] = [tile]
			else:
				_adj_list[n].append(tile)
				
		

func addTile(tile):
	pass

func removeTile(tile):
	pass

func getSize():
	return _tiles.size()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
