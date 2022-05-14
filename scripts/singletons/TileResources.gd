extends Node

var scenes = {
	"desert": preload("res://scenes/tiles/DesertTile.tscn"),
	"forest": preload("res://scenes/tiles/ForestTile.tscn"),
	"ocean": preload("res://scenes/tiles/OceanTile.tscn"),
	"coast": preload("res://scenes/tiles/CoastTile.tscn"),
	"base": preload("res://scenes/tiles/Tile.tscn"),
	"emptyland": preload("res://scenes/tiles/EmptyLandTile.tscn"),
	"mountain": preload("res://scenes/tiles/MountainTile.tscn"),
	"grassland": preload("res://scenes/tiles/GrasslandTile.tscn"),
	"savannah": preload("res://scenes/tiles/SavannahTile.tscn"),
	"dryrocks": preload("res://scenes/tiles/DryRocksTile.tscn"),
	"snow": preload("res://scenes/tiles/SnowTile.tscn"),
	"tundra": preload("res://scenes/tiles/TundraTile.tscn"),
	"plains": preload("res://scenes/tiles/PlainsTile.tscn")
}

enum types {
	Land,
	Water,
	Empty
}

enum gs_types {
	Map,
	Island,
	Biome,
	Ocean
}

enum generation_types {
	Chunk,
	Perlin
}

enum Directions {
	NORTH,
	NORTHEAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	NORTHWEST
}

enum NDirections {
	NORTHEAST,
	EAST,
	SOUTHEAST,
	SOUTHWEST,
	WEST,
	NORTHWEST
}

func get_opposite_direction(dir):
	match dir:
		TileResources.NDirections.NORTHEAST:
			return TileResources.NDirections.SOUTHWEST
		TileResources.NDirections.EAST:
			return TileResources.NDirections.WEST
		TileResources.NDirections.SOUTHEAST:
			return TileResources.NDirections.NORTHWEST
		TileResources.NDirections.SOUTHWEST:
			return TileResources.NDirections.NORTHEAST
		TileResources.NDirections.WEST:
			return TileResources.NDirections.EAST
		TileResources.NDirections.NORTHWEST:
			return TileResources.NDirections.SOUTHEAST
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
