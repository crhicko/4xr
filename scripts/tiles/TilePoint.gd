extends Polygon2D
class_name TilePoint

enum FACING {
	NORTH,
	SOUTH
}

var orientation

onready var Hitbox = $Hitbox
onready var CollisionBox = $Hitbox/CollisionBox

var has_river = false
var has_crossing = false

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

func connect_points(pt, dir_to):
	connections[dir_to] = pt
	pt.connections[TileResources.get_opposite_ndirection(dir_to)] = self

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
