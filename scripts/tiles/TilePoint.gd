extends Polygon2D
class_name TilePoint

var orientation

onready var Hitbox = $Hitbox
onready var CollisionBox = $Hitbox/CollisionBox

var has_river = false
var rivers = []
var has_crossing = false
export(bool) var is_occupied = false

var gs_neighbors = []

var connections = {
	TileResources.Directions.NORTH: null,
	TileResources.Directions.SOUTHEAST: null,
	TileResources.Directions.SOUTHWEST: null,
	TileResources.Directions.SOUTH: null,
	TileResources.Directions.NORTHWEST: null,
	TileResources.Directions.NORTHEAST: null
}

var edge_connections = {
	TileResources.NDirections.NORTHEAST: null,
	TileResources.NDirections.EAST: null,
	TileResources.NDirections.SOUTHEAST: null,
	TileResources.NDirections.SOUTHWEST: null,
	TileResources.NDirections.WEST: null,
	TileResources.NDirections.NORTHWEST: null,
}

var gs_neighbor_directions

func determine_neighbor_directions():
	var dirs
	var temp_n = gs_neighbors
	if orientation == TileResources.POINTFACING.NORTH:
		dirs = {
			TileResources.Directions.NORTHWEST: null,
			TileResources.Directions.NORTHEAST: null,
			TileResources.Directions.SOUTH: null
		}
		for n in gs_neighbors:
			if int(n.position.x) == int(self.position.x):
				dirs[TileResources.Directions.SOUTH] = n
			elif int(self.position.x) < int(n.position.x):
				dirs[TileResources.Directions.NORTHWEST] = n
			elif int(self.position.x) > int(n.position.x):
				dirs[TileResources.Directions.NORTHEAST] = n
	else:
		dirs = {
			TileResources.Directions.SOUTHWEST: null,
			TileResources.Directions.SOUTHEAST: null,
			TileResources.Directions.NORTH: null
		}
		for n in gs_neighbors:
			if int(n.position.x) == int(self.position.x):
				dirs[TileResources.Directions.NORTH] = n
			elif int(self.position.x) < int(n.position.x):
				dirs[TileResources.Directions.SOUTHWEST] = n
			elif int(self.position.x) > int(n.position.x):
				dirs[TileResources.Directions.SOUTHEAST] = n
#	assert(dirs.values()[0] != dirs.values()[1] and dirs.values()[2] != dirs.values()[1] and dirs.values()[0] != dirs.values()[2])
	gs_neighbor_directions = dirs
	return

func connect_points(pt, dir_to):
	connections[dir_to] = pt
	pt.connections[TileResources.get_opposite_ndirection(dir_to)] = self
	
func set_is_occupied(val: bool):
	is_occupied = val

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
