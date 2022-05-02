extends Node

var scenes = {
	"desert": preload("res://scenes/tiles/DesertTile.tscn"),
	"forest": preload("res://scenes/tiles/ForestTile.tscn"),
	"ocean": preload("res://scenes/tiles/OceanTile.tscn"),
	"coast": preload("res://scenes/tiles/CoastTile.tscn"),
	"base": preload("res://scenes/tiles/Tile.tscn"),
	"emptyland": preload("res://scenes/tiles/EmptyLandTile.tscn"),
	"mountain": preload("res://scenes/tiles/MountainTile.tscn"),
	"grassland": preload("res://scenes/tiles/GrasslandTile.tscn")
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
