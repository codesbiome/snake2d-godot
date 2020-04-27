extends Area2D

# Variables & Data
var _direction: Vector2 = Vector2.RIGHT;
var _accumulator: float = 0;
var _rng = RandomNumberGenerator.new();
var _foodSpawnRanges;
var _hasFood: bool = false;

# Resources
const FOOD = preload("res://Scenes/Food.tscn");

# Constants
const MOVEMENT_STEP_TIME = 0.2; # seconds
const MOVEMENT_STEP_SIZE = 32; # pixels

# Called when the node enters the scene tree for the first time.
func _ready():
	# Randomize
	randomize();
	# Spawn ranges of our viewport on X axis
	_foodSpawnRanges = food_spawnRanges();
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
	# Lets move snake
	var rel_vec = _direction * stepSize;
	# var collision = move_and_collide(rel_vec);
	translate(rel_vec);
	# Snake has the food to eat?
	if !_hasFood: food_spawner();
	pass

#-------------------------------------
# Input Handler
#-------------------------------------
func input_handler():
	# Handle movement inputs UP, DOWN, LEFT, RIGHT
	if Input.is_action_pressed("ui_up"):
		_direction = Vector2.UP;
	elif Input.is_action_pressed("ui_down"):
		_direction = Vector2.DOWN;
	elif Input.is_action_pressed("ui_left"):
		_direction = Vector2.LEFT;
	elif Input.is_action_pressed("ui_right"):
		_direction = Vector2.RIGHT;

#-------------------------------------
# Food Spawn Ranges
#-------------------------------------
func food_spawnRanges():
	return {
		"x": range(MOVEMENT_STEP_SIZE, get_viewport().size.x - MOVEMENT_STEP_SIZE, MOVEMENT_STEP_SIZE),
		"y": range(MOVEMENT_STEP_SIZE, get_viewport().size.y - MOVEMENT_STEP_SIZE, MOVEMENT_STEP_SIZE)
	};

#-------------------------------------
# Food Spawner
#-------------------------------------
func food_spawner():
	# Random spawn range on X axis
	var randomSpawnX = _foodSpawnRanges.x[randi() % _foodSpawnRanges.x.size()];
	var randomSpawnY = _foodSpawnRanges.y[randi() % _foodSpawnRanges.y.size()];
	var food = FOOD.instance();
	food.position = Vector2(randomSpawnX, randomSpawnY);
	get_parent().add_child(food);
	_hasFood = true;


func _on_Snake_body_entered(body):
	if "Wall" in body.name:
		print("DIE!");

func _on_Snake_area_entered(area):
	if "Food" in area.name:
		print("FOOD!");
		area.queue_free();
		call_deferred('food_spawner');
	pass # Replace with function body.
