extends Node3D

var drop_countdown = 0.0
var drop_countdown_max = .5
var packed_egg = preload("res://egg.tscn")

var egg1
var egg2

var board = []
const BOARD_ROWS = 12
const BOARD_COLS = 6

var isGameOver = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_eggs()
	
	for i in range(BOARD_ROWS * BOARD_COLS):
		board.append(0)
		
#	set_egg(1, 0, 1)
#	print(get_egg(1, 0))
	isGameOver = false
	
	
	pass # Replace with function body.

func set_egg(col: int, row: int, value: int):
	var i = row * BOARD_COLS + col
	if i < board.size() and i >= 0:
		board[i] = value
		
	if row > BOARD_ROWS - 1:
		isGameOver = true
		print("Game Over")
	
func get_egg(col: int, row: int) -> int:
	var i = row * BOARD_COLS + col
	if i < board.size() and i >= 0:
		return board[i]
	else: 
		return -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if isGameOver:
		return
	
	if (Input.is_action_just_pressed("left") and egg1.col > 0 and egg2.col > 0 and get_egg(egg1.col - 1, egg1.row) == 0 and get_egg(egg2.col - 1, egg2.row) == 0):
		egg1.col -= 1
		egg2.col -= 1

	if (Input.is_action_just_pressed("right") and egg1.col < BOARD_COLS - 1 and egg2.col < BOARD_COLS - 1  and get_egg(egg1.col + 1, egg1.row) == 0 and get_egg(egg2.col + 1, egg2.row) == 0):
		egg1.col += 1
		egg2.col += 1

	if (Input.is_action_just_pressed("rotate")):
		var next_row
		var next_col
		if egg1.row == egg2.row:
			if egg1.col == egg2.col - 1:
				next_row = egg1.row - 1
				next_col = egg1.col
			elif egg1.col == egg2.col + 1:
				next_row = egg1.row + 1
				next_col = egg1.col
		elif egg1.col == egg2.col:
			if egg1.row == egg2.row - 1:
				next_row = egg1.row
				next_col = egg1.col + 1
			elif egg1.row == egg2.row + 1:
				next_row = egg1.row
				next_col = egg1.col - 1
		
		if next_row >= 0 and next_row < BOARD_ROWS - 1 and next_col >= 0 and next_col < BOARD_COLS - 1:
			egg2.row = next_row
			egg2.col = next_col
		
	
	drop_countdown -= delta
	if (drop_countdown <= 0 or Input.is_action_just_pressed("down")):
		drop_countdown = drop_countdown_max
		
		if egg1.row == 0 or egg2.row == 0:
			#add to board and spawn new eggs
			set_egg(egg1.col, egg1.row, 1)
			set_egg(egg2.col, egg2.row, 1)
			_spawn_eggs()
		elif get_egg(egg1.col, egg1.row - 1) > 0 or get_egg(egg2.col, egg2.row - 1) > 0: 
			var egg1_row_drop = egg1.row
			while egg1_row_drop > 0 and get_egg(egg1.col, egg1_row_drop - 1) == 0 and not (egg1.row - 1 == egg2.row and egg1.col == egg2.col):
				egg1_row_drop -= 1
			egg1.row = egg1_row_drop
			set_egg(egg1.col, egg1.row, 1)

			var egg2_row_drop = egg2.row
			while egg2_row_drop > 0 and get_egg(egg2.col, egg2_row_drop - 1) == 0 and not (egg2.row - 1 == egg1.row and egg2.col == egg1.col):
				egg2_row_drop -= 1
			egg2.row = egg2_row_drop
			set_egg(egg2.col, egg2.row, 1)
			_spawn_eggs()
		else:
			egg1.row -= 1
			egg2.row -= 1

func _spawn_eggs() -> void:
	egg1 = packed_egg.instantiate()
	egg2 = packed_egg.instantiate()
	add_child(egg1)
	add_child(egg2)
	
	egg1.setEggColor(randi() % 4 + 1)
	egg2.setEggColor(randi() % 4 + 1)

	egg1.setCell(3, 11)
	
	egg2.setCell(3, 12)
	
