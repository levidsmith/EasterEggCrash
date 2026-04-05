extends Node3D

var drop_countdown = 0.0
var drop_countdown_max = .5
var packed_egg = preload("res://scenes/egg.tscn")

var egg1
var egg2

var num_level = 0

var board_eggs = []

const BOARD_ROWS = 12
const BOARD_COLS = 6

var goal = {"red": 2, "green": 2, "yellow": 2, "blue": 2}

enum State {READY, PLAYING, GAMEOVER, COMPLETE}
var gamestate: State = State.READY

var readyDelay: float

var soundDrop



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	init_ready()

func init_ready():
	gamestate = State.READY
	readyDelay = 3.0

	for egg in board_eggs:
		if egg != null:
			egg.destroy()
	
	if egg1 != null:
		egg1.destroy()
	if egg2 != null:
		egg2.destroy()
	
	board_eggs.clear()
	
	match num_level:
		0:
			goal = {"red": 2, "green": 2, "yellow": 2, "blue": 2}
		1:
			goal = {"red": 5, "green": 5, "yellow": 5, "blue": 5}
		2:
			goal = {"red": 10, "green": 10, "yellow": 10, "blue": 10}
		_:
			goal = {"red": 20, "green": 20, "yellow": 20, "blue": 20}
	
	var panel_gameover = get_node("/root/Node3D/PanelGameOver")
	panel_gameover.visible = false
	var panel_complete = get_node("/root/Node3D/PanelComplete")
	panel_complete.visible = false
	var panel_ready = get_node("/root/Node3D/PanelReady")
	panel_ready.visible = true

	var label_level = get_node("/root/Node3D/PanelLevel/RichTextLabelLevel")
	label_level.text = "LEVEL %d" % (num_level + 1)

	updateGoalDisplay()


func init_playing():
	gamestate = State.PLAYING
	_spawn_eggs()
	for i in range(BOARD_ROWS * BOARD_COLS):
		board_eggs.append(null)

func init_gameover():
	gamestate = State.GAMEOVER
	var panel_gameover = get_node("/root/Node3D/PanelGameOver")
	panel_gameover.visible = true

func init_complete():
	gamestate = State.COMPLETE
	
	num_level += 1
	
	var panel_complete = get_node("/root/Node3D/PanelComplete")
	panel_complete.visible = true


func set_egg(col: int, row: int, egg: Node3D):
	var i = row * BOARD_COLS + col
	if i < board_eggs.size() and i >= 0:
		board_eggs[i] = egg
		
	if row > BOARD_ROWS - 1:
		init_gameover()
	
func get_egg(col: int, row: int) -> Node3D:
	var i = row * BOARD_COLS + col
	if i < board_eggs.size() and i >= 0:
		return board_eggs[i]
	else: 
		return null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gamestate == State.READY:
		updateReady(delta)
	elif gamestate == State.PLAYING:
		updatePlaying(delta)
	elif gamestate == State.GAMEOVER:
		updateGameOver(delta)
	elif gamestate == State.COMPLETE:
		updateComplete(delta)


		
func updateReady(delta: float) -> void:
	if readyDelay > 0:
		readyDelay -= delta
		
		if readyDelay <= 0:
			var panel_ready = get_node("/root/Node3D/PanelReady")
			panel_ready.visible = false
			init_playing()
	
func updatePlaying(delta: float) -> void:
	
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

		
	
	drop_countdown -= delta
	if (drop_countdown <= 0 or Input.is_action_just_pressed("down")):
		drop_countdown = drop_countdown_max

		var iCrashCount = 0
		var iCrashCountTotal = 0
		var hasBlocksLanded = false
		if egg1.row == 0 or egg2.row == 0:
			#add to board and spawn new eggs
			set_egg(egg1.col, egg1.row, egg1)
			set_egg(egg2.col, egg2.row, egg2)
#			iCrashCount = doCrash()
#			_spawn_eggs()
			hasBlocksLanded = true
		elif get_egg(egg1.col, egg1.row - 1) != null or get_egg(egg2.col, egg2.row - 1) != null: 
#			var egg1_row_drop = egg1.row
#			while egg1_row_drop > 0 and get_egg(egg1.col, egg1_row_drop - 1) == null and not (egg1.row - 1 == egg2.row and egg1.col == egg2.col):
#				egg1_row_drop -= 1
#			egg1.row = egg1_row_drop
			set_egg(egg1.col, egg1.row, egg1)

#			var egg2_row_drop = egg2.row
#			while egg2_row_drop > 0 and get_egg(egg2.col, egg2_row_drop - 1) == null and not (egg2.row - 1 == egg1.row and egg2.col == egg1.col):
#				egg2_row_drop -= 1
#			egg2.row = egg2_row_drop
			set_egg(egg2.col, egg2.row, egg2)
#			iCrashCount = doCrash()
#			dropAllEggs()
#			_spawn_eggs()
			hasBlocksLanded = true
		else:
			egg1.row -= 1
			egg2.row -= 1
			
		if hasBlocksLanded:
			get_node("/root/Node3D/audioDrop").play()
			
			dropAllEggs()
			iCrashCount = doCrash()
			iCrashCountTotal = iCrashCount
			while iCrashCount > 0:
				dropAllEggs()
				iCrashCount = doCrash()
				iCrashCountTotal += iCrashCount
				
			if iCrashCountTotal == 0:
				get_node("/root/Node3D/audioDrop").play()
			else:
				get_node("/root/Node3D/audioCrash").play()

			
			
			_spawn_eggs()
			
			
		if iCrashCountTotal > 0:
			pass
			#dropAllEggs()

			updateGoalDisplay()
			if goal["red"] == 0 and goal["green"] == 0 and goal["yellow"] == 0 and goal["blue"] == 0:
				init_complete()


func updateGameOver(delta: float) -> void:
	if (Input.is_action_just_pressed("rotate")):
		init_ready()

func updateComplete(delta: float) -> void:
	if (Input.is_action_just_pressed("rotate")):
		init_ready()

func updateGoalDisplay():
	var label_goal = get_node("/root/Node3D/PanelGoal/RichTextLabelGoal")
	label_goal.text = "GOALS\nRED %d\nGREEN %d\nYELLOW %d\nBLUE %d" % [goal["red"], goal["green"], goal["yellow"], goal["blue"]]

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
	
func doCrash() -> int:
	var iCrashCount = 0
	for i in range(0, BOARD_ROWS):
		for j in range(0, BOARD_COLS):
			var egg = get_egg(j, i)
			if egg != null and egg.isCrash:
				var connected = []
				connected.append(egg)
				getCrashConnected(egg, connected)
				
				if connected.size() > 1:
					for eggCrashed in connected:
						if not eggCrashed.isCrash:
							updateGoal(eggCrashed.color)
						set_egg(eggCrashed.col, eggCrashed.row, null)
						eggCrashed.destroy()
					iCrashCount += connected.size()
						
	return iCrashCount

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

		
		
func getCrashConnected(egg: Node3D, connected):
	var eggNext
	
	eggNext = get_egg(egg.col + 1, egg.row)
	if eggNext != null and not eggNext in connected and eggNext.color == egg.color:
		connected.append(eggNext)
		getCrashConnected(eggNext, connected)

	eggNext = get_egg(egg.col - 1, egg.row)
	if eggNext != null and not eggNext in connected and eggNext.color == egg.color:
		connected.append(eggNext)
		getCrashConnected(eggNext, connected)

	eggNext = get_egg(egg.col, egg.row + 1)
	if eggNext != null and not eggNext in connected and eggNext.color == egg.color:
		connected.append(eggNext)
		getCrashConnected(eggNext, connected)

	eggNext = get_egg(egg.col, egg.row - 1)
	if eggNext != null and not eggNext in connected and eggNext.color == egg.color:
		connected.append(eggNext)
		getCrashConnected(eggNext, connected)

func dropAllEggs():
	for i in range(0, BOARD_ROWS):
		for j in range(0, BOARD_COLS):
			var egg = get_egg(j, i)
			if egg != null:
				var new_row = egg.row
				while (new_row - 1 >= 0 and get_egg(j, new_row - 1) == null):
					new_row -= 1
				set_egg(egg.col, egg.row, null)
				egg.row = new_row
				set_egg(egg.col, egg.row, egg)

				
			
	
