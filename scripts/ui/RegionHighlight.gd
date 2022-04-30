extends MenuButton


var _options = {
	
}

onready var Popup: PopupMenu = get_popup()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_popup().connect("index_pressed", self, "_on_index_pressed")
	SignalManager.connect("region_created", self, "add_list_option")
	SignalManager.connect("region_removed", self, "remove_list_option")
	
func _on_index_pressed(index):
	var t = Popup.get_item_text(index)
	for gs in _options[t].get_all_grid_spaces():
		gs.get_tile().highlight_toggle()
			
func add_list_option(region):
#	var popup: PopupMenu = self.get_popup()
	Popup.add_check_item(region._name)
	_options[region._name] = region
	
func remove_list_option(_name):
	_options.erase(_name)
	var index = null
	for i in range(Popup.item_count):
		var t = Popup.get_item_text(i)
		if t == _name:
			index = i;
			break;
	Popup.remove_item(index)
	

