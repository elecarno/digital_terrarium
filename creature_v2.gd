extends CharacterBody2D

@onready var c_food = get_node("../c_food")
@onready var target_line: Line2D = get_node("target_line")
@onready var label_p: Label = get_node("label_p")
@onready var label_s: Label = get_node("label_s")

enum FOCUS {REST, WANDER, HUNT}

@export var STARTING_FOCUS: FOCUS = FOCUS.REST
@export var P_INTERVAL: 	float = 2.0
@export var S_INTERVAL: 	float = 0.25
@export var CONCENTRATION:  float = 0.5 # percentage chance of retaining focus
@export var HERBIVORE:		bool = true
@export var CARNIVORE:		bool = false

@export var SPEED:			float = 150.0
@export var JUMP_VELOCITY:  float = -300.0

@onready var focus: FOCUS = STARTING_FOCUS
var target_food = null

var direction: float
var dir_target_food: Vector2
var detect_l: bool = false
var detect_r: bool = false

func _ready() -> void:
	get_node("personality").wait_time = P_INTERVAL
	get_node("survival").wait_time = S_INTERVAL

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if target_food != null:
		dir_target_food = c_food.get_child(target_food).position - global_transform.origin
		target_line.set_point_position(1, dir_target_food)
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# actions
func a_move(dir): # -1 to 1, 0 for stop
	direction = dir

func a_jump(str): # 0 to 1 multiplier
	if is_on_floor():
		velocity.y = JUMP_VELOCITY * str

# brain timers
func _on_personality_timeout() -> void:
	var change_focus = randf()
	if change_focus > CONCENTRATION:
		focus = FOCUS.values()[randi()%FOCUS.size()]
		target_food = null
		msg(0, "change focus to " + FOCUS.keys()[focus])
		
	if focus != FOCUS.HUNT:
		target_line.set_point_position(1, Vector2.ZERO)

func _on_survival_timeout() -> void:
	# focus actions
	if focus == FOCUS.REST:
		a_move(0)
		msg(1, "stop moving")
	elif focus == FOCUS.WANDER:
		var dir = randi_range(-1, 1)
		a_move(dir)
		msg(1, "move in dir %0.0f (wander)" % [dir])
	elif focus == FOCUS.HUNT:
		if HERBIVORE:
			if c_food.get_child_count() > 0 and target_food == null:
				target_food = randi_range(0, c_food.get_child_count() - 1)
				msg(0, "targeted food " + str(target_food))
	
	# resulting actions
	if target_food != null:
		var dir = dir_target_food.normalized().x
		a_move(dir)
		msg(1, "move in dir %0.0f (food)" % [dir])
		
		if dir_target_food.y < -24 and abs(dir_target_food.x) < 32:
			a_jump(1)
			msg(1, "jump (food)")
	
	if detect_r or detect_l:
		a_jump(1)
		msg(1, "jump (obstacle)")

# display
func msg(brain, string):
	global.feed_msg(name + "  (" + str(brain) + ") : " + string)
	if brain == 0:
		label_p.text = string
	elif brain == 1:
		label_s.text = string

# detectors
func _on_detect_r_body_entered(body: Node2D) -> void:
	detect_r = true
	msg(1, "detect right")

func _on_detect_l_body_entered(body: Node2D) -> void:
	detect_l = true
	msg(1, "detect left")

func _on_detect_r_body_exited(body: Node2D) -> void:
	detect_r = false
	msg(1, "stop detect right")

func _on_detect_l_body_exited(body: Node2D) -> void:
	detect_l = false
	msg(1, "stop detect left")

func _on_detect_food_area_entered(food: Area2D) -> void:
	msg(1, "detect food")
	if target_food != null:
		if food.is_in_group("food") and food.name == c_food.get_child(target_food).name:
			var target_food_id_store = target_food
			target_food = null
			food.eat()
			target_line.set_point_position(1, Vector2.ZERO)
			msg(0, "eaten food " + str(target_food_id_store))
			
			if c_food.get_child_count() == 0:
				focus = FOCUS.REST
				msg(0, "no food left, switching focus to REST.")
