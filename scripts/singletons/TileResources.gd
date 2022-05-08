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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
