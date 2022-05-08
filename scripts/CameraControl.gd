extends Camera2D


var zoomdist = 0;
var EDGE_THRESHHOLD = 10;
var MAX_ZOOM_LEVEL = 5;
var _zoom_level = 0;



func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position();
	var camera_size = get_viewport_rect().size
	if mouse_pos.x < EDGE_THRESHHOLD:
		offset.x -= 10
	elif mouse_pos.x > camera_size.x - EDGE_THRESHHOLD:
		offset.x += 10
	
	if mouse_pos.y < EDGE_THRESHHOLD:
		offset.y -= 10
	elif mouse_pos.y > camera_size.y - EDGE_THRESHHOLD:
		offset.y += 10
		

	if Input.is_action_just_pressed("zoom_out") and _zoom_level != -MAX_ZOOM_LEVEL:
		print("zooming out")
		_zoom_level -= 1
		zoom *= Vector2(1.2,1.2)
		print(zoom)
	elif Input.is_action_just_pressed("zoom_in") and _zoom_level != MAX_ZOOM_LEVEL:
		print("zooming in")
		_zoom_level += 1
		zoom /= Vector2(1.2,1.2)
		print(zoom)
	elif Input.is_action_just_pressed("pan_left"):
		offset += Vector2(-300,0);
	elif Input.is_action_just_pressed("pan_right"):
		offset += Vector2(300,0);
	elif Input.is_action_just_pressed("pan_up"):
		offset += Vector2(0,-300);
	elif Input.is_action_just_pressed("pan_down"):
		offset += Vector2(0,300);
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Camera Loaded")
