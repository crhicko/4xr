extends Node

var scenes = {
	"desert": preload("res://scenes/tiles/DesertTile.tscn"),
	"forest": preload("res://scenes/tiles/ForestTile.tscn"),
	"ocean": preload("res://scenes/tiles/OceanTile.tscn"),
	"coast": preload("res://scenes/tiles/CoastTile.tscn"),
	"base": preload("res://scenes/tiles/Tile.tscn"),
	"emptyland": preload("res://scenes/tiles/EmptyLandTile.tscn")
}

enum types {
	Land,
	Water,
	Empty
}


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
