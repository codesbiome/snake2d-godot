extends Sprite

# Variables & Data
var _direction: Vector2 = Vector2.RIGHT;
var _accumulator: float = 0;

# Constants
const MOVEMENT_STEP_TIME = 0.2; # seconds
const MOVEMENT_STEP_SIZE = 32; # pixels

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called during the physics processing step of the main loop.
func _physics_process(delta):
	movement_step_handler(delta);
	pass

# Calls movement at certain tickrate
func movement_step_handler(deltaTime: float):
	# Accmulate with Delta time
	_accumulator += deltaTime;

	# Check if accumulation went over step-time
	if (_accumulator > MOVEMENT_STEP_TIME):
		# Negate accmulation
		_accumulator -= MOVEMENT_STEP_TIME;
		# Call movement
		movement(MOVEMENT_STEP_SIZE);


# Move Snake
func movement(stepSize: int):
	# Lets move snake
	translate(_direction * stepSize);
	pass
