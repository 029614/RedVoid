extends KinematicBody2D

""" -------- DECLARATION -------- """
onready var bodies = get_parent().get_node("Bodies")
onready var engine = get_parent()
onready var launch_origin = get_parent().get_node("Start").get_global_position()
onready var last_position = get_position()

#input and direction
var horizontal_input
var vertical_input
var velocity = Vector2()
var rotation_dir = 0

#Ship
var thrust = 999
var mass = 10
export var fuel = 2500

#Ship Components
var fuel_tank_tier = 1 #1-3
var engine_tier = 1 #1-3
var shields_tier = 0 #0-3
var cargo_tier = 1 #1-3
var weapons_tier = 0 #0-3
var jump_drive = false

#launcher
var power = 0
var power_indicator = 0
var launch_speed = 10

#physics
var acceleration = 0
var inertia = 0
var friction = 1

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 2
var current_speed = 0
var max_speed = 99999


""" -------- FUNCTIONS -------- """
#initialize variables
func _ready():
    set_process_input(true)
    acceleration = thrust/mass
    Global.connect("player_landed", self, "land")



func get_input(delta):
    rotation_dir = 0
    if Input.is_action_pressed('ui_right'):
        rotation_dir += 1
    if Input.is_action_pressed('ui_left'):
        rotation_dir -= 1
    if Input.is_action_pressed('ui_down'):
        pass
    if Input.is_action_pressed('ui_up') and fuel >= 0:
        $Sprite.hide()
        $Flying.show()
        current_speed = velocity.length()
        velocity += Vector2(acceleration*delta, 0).rotated(rotation).normalized()
        velocity = velocity.clamped(max_speed)
        fuel -= 1
    else:
        $Sprite.show()
        $Flying.hide()

func _physics_process(delta):
    if Global._is_player_picked == false and Global._process_player_movement == true and Global._player_is_landed == true:
        get_input(delta)
        get_gravity(delta)
        rotation += rotation_dir * rotation_speed * delta
        velocity = Vector2(lerp(velocity.x, 0, friction), lerp(velocity.y, 0, friction))
        velocity = move_and_slide(velocity)
    if Global._is_player_picked == false and Global._process_player_movement == true:
        get_input(delta)
        get_gravity(delta)
        rotation += rotation_dir * rotation_speed * delta
        velocity = move_and_slide(velocity)
        var move_overlay = get_position() - last_position
        last_position = get_position()
        engine.overlay.set_position(engine.overlay.get_position() - move_overlay/2)
    elif Global._is_player_picked == true:
        var new_position = get_global_mouse_position()
        if new_position.distance_to(launch_origin) > 200:
            pass
        else:
            self.set_global_position(new_position)
            power_indicator = self.global_position.distance_to(launch_origin) * 2
            power = self.global_position.distance_to(launch_origin) * 2
        self.look_at(launch_origin)

func _input_event(viewport, event, shape_idx):
    if _event_is_left_click(event): # check if left click is pressed on the body
        print(event.pressed)
        Global._is_player_picked = event.pressed

func _input(event): # check if left click is released even outside of the body
    if _event_is_left_click(event) and not event.pressed and Global._is_player_picked == true:
        if Global._player_is_launched == false:
            launch()
            Global._player_is_launched = true
    if _event_is_left_click(event) and not event.pressed:
        Global._is_player_picked = false
    if Global._player_is_landed == true and Input.is_action_just_pressed("weapons"):
        print("player launch")
        Global._player_is_landed == false
        velocity += Vector2(1, 0).rotated(rotation).normalized()*launch_speed
        velocity = move_and_slide(velocity)

func _event_is_left_click(event):
    return event is InputEventMouseButton and event.button_index == BUTTON_LEFT

func get_gravity(delta):
    for body in bodies.get_children():
        velocity += ( body.mass / (body.position.distance_to(self.position)) * self.position.direction_to(body.position) ) * delta

func launch():
    velocity += Vector2(1, 0).rotated(rotation).normalized()*power
    velocity = move_and_slide(velocity)
    Global._process_player_movement = true
    $Highlighter.hide()
    $ChaseCamera.make_current()

func land(planet):
    Global._player_is_landed = true
#    self.set_global_position(planet.get_global_position())
#    _has_launched = false
#    _process_movement = false
#    launch_origin = planet.get_global_position()
#    fuel = 250
#    $Highlighter.show()
