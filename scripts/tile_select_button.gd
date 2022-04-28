extends MenuButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _tile = null

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("id_pressed", self, "_on_id_pressed")

func _on_id_pressed(id):
	SignalManager.connect("grid_space_clicked", self, "_place_tile")
	match id:
		0:
			_tile = TileResources.scenes.desert.instance()
		1:
			_tile = TileResources.scenes.forest.instance()
		2:
			_tile = TileResources.scenes.ocean.instance()
		
		
	
func _place_tile(gridSpace: GridSpace):
	print("placing tile")
	gridSpace.set_tile(_tile)
	SignalManager.disconnect("grid_space_clicked", self, "_place_tile")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

