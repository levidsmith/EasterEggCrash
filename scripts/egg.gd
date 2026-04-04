extends Node3D

var row
var col
var color
var isCrash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = Vector3(col + 0.5, row + 0.5, 0)
	pass

func setEggColor(c):
#	$egg.get_mesh()
	var egg_red = get_node("./egg_red")
	var egg_green = get_node("./egg_green")
	var egg_yellow = get_node("./egg_yellow")
	var egg_blue = get_node("./egg_blue")

	var diamond_red = get_node("./diamond_red")
	var diamond_green = get_node("./diamond_green")
	var diamond_yellow = get_node("./diamond_yellow")
	var diamond_blue = get_node("./diamond_blue")
	
	if isCrash:
		match c:
			1:
				diamond_red.visible = true
			2:
				diamond_green.visible = true
			3:
				diamond_yellow.visible = true
			4:
				diamond_blue.visible = true
	else:
		match c:
			1:
				egg_red.visible = true
			2:
				egg_green.visible = true
			3:
				egg_yellow.visible = true
			4:
				egg_blue.visible = true
	

func setCrash(b):
	isCrash = b
	
func setCell(new_col: int, new_row: int):
	row = new_row
	col = new_col
	global_position = Vector3(col + 0.5, row + 0.5, 0)
