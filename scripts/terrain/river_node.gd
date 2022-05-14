extends Node2D

export(NodePath) var c_neighbor
export(NodePath) var cc_neighbor
export(bool) var active
export(int) var _position

func set_active(f: bool):
	active = f

#returns the connection points in cw order
func get_connection_neighbor_dirs():
	match position:
		TileResources.Directions.NORTH:
			return [TileResources.Directions.SOUTHEAST, TileResources.Directions.SOUTHWEST]
		TileResources.Directions.NORTHEAST:
			return [TileResources.Directions.SOUTH, TileResources.Directions.NORTHWEST]
		TileResources.Directions.SOUTHEAST:
			return [TileResources.Directions.SOUTHWEST, TileResources.Directions.NORTH]
		TileResources.Directions.SOUTH:
			return [TileResources.Directions.NORTHWEST, TileResources.Directions.NORTHEAST]
		TileResources.Directions.SOUTHWEST:
			return [TileResources.Directions.NORTH, TileResources.Directions.SOUTHEAST]
		TileResources.Directions.NORTHWEST:
			return [TileResources.Directions.NORTHEAST, TileResources.Directions.SOUTH]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
