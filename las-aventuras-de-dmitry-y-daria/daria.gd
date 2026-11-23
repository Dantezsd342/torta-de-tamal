extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false


func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)


# Detecta cuando se presiona la tecla X una sola vez
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_X and not is_attacking:
			is_attacking = true
			anim.play("attack")


func _physics_process(delta: float) -> void:
	# 1. Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Movimiento horizontal y dirección del sprite
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not is_attacking:
			anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	# 4. Actualizar animaciones
	update_animations(direction)


func update_animations(direction: float) -> void:
	if is_attacking:
		return

	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		anim.play("run")
	else:
		anim.play("idle")


func _on_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
