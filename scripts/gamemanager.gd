extends Node3D

var drop_countdown = 0.0
var drop_countdown_max = .5
var packed_egg = preload("res://scenes/egg.tscn")

var egg1
var egg2

var board_eggs = []

const BOARD_ROWS = 12
const BOARD_COLS = 6

var isGameOver = true

var goal = {"red": 5, "green": 5, "yellow": 5, "blue": 5}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_eggs()
	
	for i in range(BOARD_ROWS * BOARD_COLS):
		board_eggs.append(null)
		
	isGameOver = false
	
	pass # Replace with function body.

func set_egg(col: int, row: int, egg: Node3D):
	var i = row * BOARD_COLS + col
	if i < board_eggs.size() and i >= 0:
		board_eggs[i] = egg
		
	if row > BOARD_ROWS - 1:
		isGameOver = true
		print("Game Over")
		var panel_gameover = get_node("/root/Node3D/PanelGameOver")
		panel_gameover.visible = true


	
func get_egg(col: int, row: int) -> Node3D:
	var i = row * BOARD_COLS + col
	if i < board_eggs.size() and i >= 0:
		return board_eggs[i]
	else: 
		return null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if isGameOver:
		return
	
	if (Input.is_action_just_pressed("left") and egg1.col > 0 and egg2.col > 0 and get_egg(egg1.col - 1, egg1.row) == null and get_egg(egg2.col - 1, egg2.row) == null):
		egg1.col -= 1
		egg2.col -= 1

	if (Input.is_action_just_pressed("right") and egg1.col < BOARD_COLS - 1 and egg2.col < BOARD_COLS - 1  and get_egg(egg1.col + 1, egg1.row) == null and get_egg(egg2.col + 1, egg2.row) == null):
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
		
		if next_row >= 0 and next_row < BOARD_ROWS  and next_col >= 0 and next_col < BOARD_COLS:
			egg2.row = next_row
			egg2.col = next_col

	var label_goal = get_node("/root/Node3D/PanelGoal/RichTextLabelGoal")
	label_goal.text = "GOALS\nRED %d\nGREEN %d\nYELLOW %d\nBLUE %d" % [goal["red"], goal["green"], goal["yellow"], goal["blue"]]
		
	
	drop_countdown -= delta
	if (drop_countdown <= 0 or Input.is_action_just_pressed("down")):
		drop_countdown = drop_countdown_max
		
		if egg1.row == 0 or egg2.row == 0:
			#add to board and spawn new eggs
			set_egg(egg1.col, egg1.row, egg1)
			set_egg(egg2.col, egg2.row, egg2)
			doCrash()
			_spawn_eggs()
		elif get_egg(egg1.col, egg1.row - 1) != null or get_egg(egg2.col, egg2.row - 1) != null: 
			var egg1_row_drop = egg1.row
			while egg1_row_drop > 0 and get_egg(egg1.col, egg1_row_drop - 1) == null and not (egg1.row - 1 == egg2.row and egg1.col == egg2.col):
				egg1_row_drop -= 1
			egg1.row = egg1_row_drop
			set_egg(egg1.col, egg1.row, egg1)

			var egg2_row_drop = egg2.row
			while egg2_row_drop > 0 and get_egg(egg2.col, egg2_row_drop - 1) == null and not (egg2.row - 1 == egg1.row and egg2.col == egg1.col):
				egg2_row_drop -= 1
			egg2.row = egg2_row_drop
			set_egg(egg2.col, egg2.row, egg2)
			doCrash()
			_spawn_eggs()
		else:
			egg1.row -= 1
			egg2.row -= 1

func _spawn_eggs() -> void:
	egg1 = packed_egg.instantiate()
	egg2 = packed_egg.instantiate()
	add_child(egg1)
	add_child(egg2)

	var iRand
	iRand = randi() % 5
	if iRand == 0:
		egg1.setCrash(true)
		

	iRand = randi() % 5
	if iRand == 0:
		egg2.setCrash(true)

	
	egg1.setEggColor(randi() % 4 + 1)
	egg2.setEggColor(randi() % 4 + 1)

	egg1.setCell(3, 11)
	egg2.setCell(3, 12)
	
func doCrash():
	for i in range(0, BOARD_ROWS):
		for j in range(0, BOARD_COLS):
			var egg = get_egg(j, i)
			if egg != null and egg.isCrash:
				egg.destroy()
				set_egg(j, i, null)
				var eggNext

				eggNext = get_egg(j + 1, i)
				if eggNext != null and eggNext.color == egg.color:
					updateGoal(eggNext.color)
					eggNext.destroy()
					set_egg(j + 1, i, null)

				eggNext = get_egg(j - 1, i)
				if eggNext != null and eggNext.color == egg.color:
					updateGoal(eggNext.color)
					eggNext.destroy()
					set_egg(j - 1, i, null)
				
				eggNext = get_egg(j, i + 1)
				if eggNext != null and eggNext.color == egg.color:
					updateGoal(eggNext.color)
					eggNext.destroy()
					set_egg(j, i + 1, null)

				eggNext = get_egg(j, i - 1)
				if eggNext != null and eggNext.color == egg.color:
					updateGoal(eggNext.color)
					eggNext.destroy()
					set_egg(j, i - 1, null)

func updateGoal(c):
	match c:
		1:
			if goal["red"] > 0:
				goal["red"] -= 1
		2:
			if goal["green"] > 0:
				goal["green"] -= 1
		3:
			if goal["yellow"] > 0:
				goal["yellow"] -= 1
		4:
			if goal["blue"] > 0:
				goal["blue"] -= 1

	if goal["red"] == 0 and goal["green"] == 0 and goal["yellow"] == 0 and goal["blue"] == 0:
		var panel_complete = get_node("/root/Node3D/PanelComplete")
		panel_complete.visible = true
		
