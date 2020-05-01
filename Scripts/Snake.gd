extends Area2D

# Variables & Data
var _direction: Vector2 = Vector2.RIGHT;
var _accumulator: float = 0;
var _hasFood: bool = false;
var _tail: Array;
var _grid = [];
var _free_grid = [];
var _scoreCount = 0;

# Resources
const FOOD = preload("res://Scenes/Food.tscn");
const TAIL = preload("res://Scenes/Tail.tscn");

# Constants
const MOVEMENT_STEP_TIME = 0.1; # seconds
const MOVEMENT_STEP_SIZE = 32; # pixels

signal snake_eat_food;

# Called when the node enters the scene tree for the first time.
func _ready():
	# Randomize
	randomize();
	# Setup Grid
	grid_setup();
	pass

# Called during the physics processing step of the main loop.
func _physics_process(delta):
	input_handler();
	movement_step_handler(delta);
	pass

#-------------------------------------
# Calls movement at certain tickrate
#-------------------------------------
func movement_step_handler(deltaTime: float):
	# Accmulate with Delta time
	_accumulator += deltaTime;

	# Check if accumulation went over step-time
	if (_accumulator > MOVEMENT_STEP_TIME):
		# Negate accmulation
		_accumulator -= MOVEMENT_STEP_TIME;
		# Call movement
		movement(MOVEMENT_STEP_SIZE);

#-------------------------------------
# Snake Movement
#-------------------------------------
func movement(stepSize: int):
	# Last position of snake
	var lastPosition = position;
	# Lets move snake
	var rel_vec = _direction * stepSize;
	# var collision = move_and_collide(rel_vec);
	translate(rel_vec);
	# Snake has the food to eat?
	if !_hasFood: food_spawner();
	# Have we got any tail to move?
	if _tail.size() > 0 :
		# Get last tail item
		var lastTail = _tail.back();
		# Set last tail item position to snake's last position
		lastTail.position = lastPosition;
		# Enable tail collision
		lastTail.get_node("CollisionShape2D").disabled = false;
		# Insert last tail item at first position in array
		_tail.insert(0, lastTail);
		# Remove last tail item
		_tail.remove(_tail.size() - 1);
	pass

#-------------------------------------
# Input Handler
#-------------------------------------
func input_handler():
	# Last direction of snake
	var lastDirection = _direction;

	# Handle movement inputs UP, DOWN, LEFT, RIGHT
	if Input.is_action_pressed("ui_up"):
		_direction = Vector2.UP;
	elif Input.is_action_pressed("ui_down"):
		_direction = Vector2.DOWN;
	elif Input.is_action_pressed("ui_left"):
		_direction = Vector2.LEFT;
	elif Input.is_action_pressed("ui_right"):
		_direction = Vector2.RIGHT;

	# Prevent backward movement with tail
	if lastDirection != _direction:
		if (lastDirection + _direction) == Vector2.ZERO && _tail.size():
			_direction = lastDirection;


func grid_setup():
	for x in range(MOVEMENT_STEP_SIZE, get_viewport().size.x - MOVEMENT_STEP_SIZE, MOVEMENT_STEP_SIZE):
		for y in range(MOVEMENT_STEP_SIZE, get_viewport().size.y - MOVEMENT_STEP_SIZE, MOVEMENT_STEP_SIZE):
			_grid.append(Vector2(x, y));
	pass

#-------------------------------------
# Food Spawner
#-------------------------------------
func food_spawner():
	# Allocate free grid space
	alloc_free_grid();
	# Random Spawn Position from _free_grid positions
	var randomSpawnPos = _free_grid[randi() % _free_grid.size()];
	# Create Food Instance
	var food = FOOD.instance();
	# Set Food position
	food.position = Vector2(randomSpawnPos.x, randomSpawnPos.y);
	# Add as Child
	get_parent().add_child(food);
	# Snake now has food to eat!
	_hasFood = true;
	# Print out
	print("Food Spawn at : ", randomSpawnPos);


func alloc_free_grid():
	# Clear free grid items
	_free_grid.clear();

	# Snake's full position including tail
	var snakePos = [];
	snakePos.append(position);
	for t in _tail:
		snakePos.append(t.position);

	# Lets loop through our grid positions
	for g in _grid:
		# Snake has position matching with this grid slot
		if snakePos.has(g):
			continue;

		# Add grid slot as free
		_free_grid.append(g);

#-------------------------------------
# Add tail to Snake
#-------------------------------------
func add_tail():
	# Create new tail instance and set its position to add as child
	var tail = TAIL.instance();
	tail.set_position(position);
	tail.get_node("CollisionShape2D").disabled = true;
	get_parent().call_deferred("add_child", tail);
	# Insert first tail item of snake
	_tail.insert(0, tail);
	pass

func _on_Snake_body_entered(body):
	if "Wall" in body.name:
		print("DIE!");

func _on_Snake_area_entered(area):
	if "Food" in area.name:
		print("FOOD!");
		area.queue_free();
		_hasFood = false;
		add_tail();
		emit_signal('snake_eat_food');

	if "Tail" in area.name:
		print("DIE SELF!");
	pass # Replace with function body.


func update_score():
	var score = get_node("/root/Main/ControlBar/ScoreCount") as Label;
	_scoreCount = _scoreCount + 1;
	score.text = str(_scoreCount);
	pass

func _on_Snake_snake_eat_food():
	update_score();
	pass # Replace with function body.
