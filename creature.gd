extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

@onready var c_food = get_node("../c_food")
@onready var target_line: Line2D = get_node("target_line")

var target_food = null

var detect_l: bool = false
var detect_r: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction
	var dir_food: Vector2
	
	# check if any food exists
	if c_food.get_child_count() > 0:
		# check if needs to target food
		if target_food == null or c_food.get_child(target_food) == null:
			print(name + " is choosing to target a new food")
			if c_food.get_child_count() > 0: # check any food exists
				target_food = randi_range(0, c_food.get_child_count() - 1)
				print(name + " has targeted food " + str(target_food))
		else:
			dir_food = c_food.get_child(target_food).position - global_transform.origin
			direction = dir_food.normalized().x
			target_line.set_point_position(1, dir_food)
			if dir_food.y < -24 and abs(dir_food.x) < 32 and is_on_floor():
				jump()
				print(name + " is jumping for food")
		
	if detect_r or detect_l:
		jump()
		print(name + " is jumping to overcome an obstacle")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_detect_r_body_entered(body: Node2D) -> void:
	detect_r = true
	print(name + " has detected a wall to its right")

func _on_detect_l_body_entered(body: Node2D) -> void:
	detect_l = true
	print(name + " has detected a wall to its left")

func _on_detect_r_body_exited(body: Node2D) -> void:
	detect_r = false
	print(name + " no longer detects a wall to its right")

func _on_detect_l_body_exited(body: Node2D) -> void:
	detect_l = false
	print(name + " no longer detects a wall to its left")

func _on_detect_food_area_entered(area: Area2D) -> void:
	print(name + " has detected food")
	if area.is_in_group("food") and area.name == c_food.get_child(target_food).name:
		target_food = null
		area.eat()
		print(name + " has eaten food")
