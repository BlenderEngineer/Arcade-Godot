extends CharacterBody3D

#settings
var base_speed = 10
var bullet_speed = 50
var despawn_time = 5
const ACCEL_DEFAULT = 7
const ACCEL_AIR = 1
var gravity = 0 #9.8
var jump = base_speed #5

var cam_accel = 40
var mouse_sense = 0.1

@onready var accel = ACCEL_DEFAULT

var snap

var direction = Vector3()
var face_direction = Vector3()
var vel = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

var bullet = preload("res://bullet.tscn")
@onready var head = $Head
@onready var camera = $Head/Camera
@onready var flashlight1 = $Head/Flashlight1
@onready var flashlight2 = $Head/Flashlight2
#sounds
@onready var ShootSound = $Head/Shoot
@onready var ShootAltSound = $Head/ShootAlt

func _ready(): # runs on game start
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#toggle flashlight
	if Input.is_action_pressed("flashlight"):
		flashlight1.visible = not flashlight1.visible
		flashlight2.visible = not flashlight2.visible
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))

func shootBullet(angle = -45, offset = 0):
	deg2rad(angle) #rotate the impulse vector
	face_direction = Vector3(-(transform.basis.z.x - transform.basis.z.z), 0, -(transform.basis.x.x - transform.basis.x.z))
	face_direction = Vector3(cos(angle) * face_direction.x - sin(angle) * face_direction.z, 0, sin(angle) * face_direction.x + cos(angle) * face_direction.z)
	
	var newBullet = bullet.instantiate()
	newBullet.transform = transform
	newBullet.position += Vector3(0,3 + offset,0) + face_direction
	newBullet.name = "bullet"
	newBullet.apply_impulse(face_direction * bullet_speed, position)
	get_tree().get_root().add_child(newBullet)
	await get_tree().create_timer(despawn_time).timeout
	newBullet.queue_free()

func _process(delta):
	#shooting
	if Input.is_action_pressed("fire") and not ShootSound.playing:
		shootBullet()
		ShootSound.play(.05)
	if Input.is_action_just_pressed("alt_fire") and not ShootAltSound.playing:
		ShootAltSound.play()
		#horizontal
		shootBullet(-44.5)
		shootBullet(-44.75)
		shootBullet(-45)
		shootBullet(-45.25)
		shootBullet(-45.5)
		#vertical
		shootBullet(-45, 7)
		shootBullet(-45, 3)
		
		shootBullet(-45, -3)
		shootBullet(-45, -7)
		#knockback
		vel -= vel.lerp(face_direction * base_speed/3, accel * delta)
		velocity = vel + gravity_vec
		
		move_and_slide()
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		#camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.lerp(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		#camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		
func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	var speed = base_speed
	
	#vertical movement and gravity
	
	if Input.is_action_pressed("boost"):
		# double speed
		speed = base_speed * 2
		jump = base_speed * 2
	
	if is_on_floor():
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_pressed("move_up"): #and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * jump
	elif Input.is_action_pressed("move_down"): #and is_on_floor():
		snap = Vector3.ZERO
		gravity_vec = Vector3.UP * -jump
	else:
		snap = Vector3.ZERO
		gravity_vec = Vector3.ZERO
	#make it move
	vel = vel.lerp(direction * speed, accel * delta)
	velocity = vel + gravity_vec
	
	move_and_slide()#movement, snap, Vector3.UP)
