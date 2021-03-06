extends Node
class_name Tile    

export(String) var _name 
export(int) var _terrain_type
export(bool) var _allows_hill
export(bool) var _allows_forest
export(bool) var _allows_river

var _features = {
	"hill": false,
	"forest": false,
	"river": false,
	"headwater": false
}

var inset_point_pos = {
	TileResources.Directions.NORTH: Vector2(0,-30),
	TileResources.Directions.NORTHEAST: Vector2(26,-10),
	TileResources.Directions.SOUTHEAST: Vector2(26, 10),
	TileResources.Directions.SOUTH: Vector2(0, 30),
	TileResources.Directions.SOUTHWEST: Vector2(-26, 10),
	TileResources.Directions.NORTHWEST: Vector2(-26, -10),
}

var inset_points = {
	TileResources.Directions.NORTH: null,
	TileResources.Directions.NORTHEAST: null,
	TileResources.Directions.SOUTHEAST: null,
	TileResources.Directions.SOUTH: null,
	TileResources.Directions.SOUTHWEST: null,
	TileResources.Directions.NORTHWEST: null,
}

export(Dictionary) var yields = {
	"production": 0,
	"food": 0,
	"gold": 0,
	"science": 0
		
}


onready var Highlight = $Highlight

func get_name(): return _name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func highlight_on():
	Highlight.visible = true
	
func highlight_off():
	Highlight.visible = false
	
func highlight_toggle():
	Highlight.visible = !Highlight.visible
	
func set_hill(f: bool):
	if _allows_hill:
		_features.hill = f
		$HillIcon.visible = f
	
func set_forest(f: bool):
	if _allows_forest:
		_features.forest = f
		$ForestIcon.visible = f
		
func set_river(f: bool):
	if _allows_river:
		_features.river = f
		$River.visible = f

		
func get_river_nodes(dir):
	var nodes = []
	match dir:
		TileResources.NDirections.NORTHEAST:
			nodes = [get_node("RiverNodes/North"), get_node("RiverNodes/Northeast")]
		TileResources.NDirections.EAST:
			nodes = [get_node("RiverNodes/Northeast"), get_node("RiverNodes/Southeast")]
		TileResources.NDirections.SOUTHEAST:
			nodes = [get_node("RiverNodes/Southeast"), get_node("RiverNodes/South")]
		TileResources.NDirections.SOUTHWEST:
			nodes = [get_node("RiverNodes/South"), get_node("RiverNodes/Southwest")]
		TileResources.NDirections.WEST:
			nodes = [get_node("RiverNodes/Southwest"), get_node("RiverNodes/Northwest")]
		TileResources.NDirections.NORTHWEST:
			nodes = [get_node("RiverNodes/Northwest"), get_node("RiverNodes/North")]
	return nodes
	
func add_item_to_point(item,dir):
	inset_points[dir] = item
	self.add_child(item)
	item.position += inset_point_pos[dir]
	
func remove_item_from_point(dir):
	var temp = inset_points[dir]
	inset_points[dir] = null
	self.remove_child(temp)
	return temp
	
func get_item_at_point(dir):
	return inset_points[dir]
	
func get_item_dir(item):
	var index = inset_points.values().find(item)
	return index
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
