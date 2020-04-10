extends KinematicBody2D


""" -------- DECLARATION -------- """
onready var bodies = get_parent().get_node("Navigation2D/Bodies")
onready var engine = get_parent()
onready var last_position = get_position()

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var orbital_pos

#Ship
onready var thrust = 2000
var mass = 10
export var fuel = 250000

#Ship Components
var fuel_tank_tier = 1 #1-3
var engine_tier = 1 #1-3
var shields_tier = 0 #0-3
var cargo_tier = 1 #1-3
var weapons_tier = 0 #0-3

#launcher
var launch_speed = 100

#physics
var acceleration = 0
var friction = 1

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 2
var current_speed = 0
var max_speed = 99999

#flags
var _orbiting = false



""" -------- FUNCTIONS -------- """
#initialize variables
func _ready():
    
    #Connecting signals and presetting flags
    Global.connect("player_landed", self, "land")
    Global.connect("player_arrival", self, "setupOrbit")
    Global._process_player_movement = true
    
    #Other start up related shit
    acceleration = thrust/mass
    print("acceleration: ", acceleration)
    #$ParallaxBackground.set_global_position(get_global_position())

func get_input(delta):
    
    #Directional Inputs
    if Global._player_is_landed == false and _orbiting == false:
        rotation_dir = 0
        if Input.is_action_pressed('ui_right'):
            rotation_dir += 1 
        if Input.is_action_pressed('ui_left'):
            rotation_dir -= 1
        if Input.is_action_pressed('ui_down'):
            pass
        if Input.is_action_pressed('ui_up') and fuel >= 0:
        
            #Changing the sprite to the one with engine plumes
            $Sprite.hide()
            $Flying.show()
            
            #Input Movements
            current_speed = velocity.length()
            velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
            velocity = velocity.clamped(max_speed)
            fuel -= 1
        
        
        else:
            
            #Changing the sprite back to the one without engine plumes
            $Sprite.show()
            $Flying.hide()

func _physics_process(delta):
    get_input(delta)
    get_gravity(delta)
    rotation += rotation_dir * rotation_speed * delta
    if _orbiting == true:
        position = orbital_pos.get_global_position()
        rotation = orbital_pos.get_global_rotation() + deg2rad(90)
    
    #For when you land on a planet
    if Global._process_player_movement == true and Global._player_is_landed == true:
        velocity = Vector2(lerp(velocity.x, 0, friction), lerp(velocity.y, 0, friction))
        velocity = move_and_slide(velocity)
        
    #For flying around normally
    elif Global._process_player_movement == true and Global._player_is_landed == false:
        velocity = move_and_slide(velocity)
        
        #Parallax background motion
        var move_overlay = get_position() - last_position
        last_position = get_position()
        #engine.overlay.set_position(engine.overlay.get_position() - move_overlay/2)

func _input(event):
    #Orbit
    if Global._player_in_orbit == true and _orbiting == false and Input.is_action_just_pressed("orbit"):
        _orbiting = true
    elif _orbiting == true and Input.is_action_just_pressed("orbit"):
        _orbiting = false
    
    #Lift Off
    if Global._player_is_landed == true and Input.is_action_just_pressed("weapons"):
        print("player launch")
        velocity += Vector2(1, 0).rotated(rotation).normalized()*launch_speed
        velocity = move_and_slide(velocity)
        Global._player_is_landed = false
    
    #Camera Zoom
    if Input.is_action_pressed("zoom_in"):
        $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x - .1, $ChaseCamera.get_zoom().y - .1))
    if Input.is_action_pressed("zoom_out"):
        $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x + .1, $ChaseCamera.get_zoom().y + .1))

func get_gravity(delta):
    for body in bodies.get_children():
        velocity += ( body.mass / (body.position.distance_to(self.position)) * self.position.direction_to(body.position) ) * delta

func land(planet, orbit):
    Global._player_is_landed = true
    print("player is landed")
    Global.emit_signal("capture_planet", Global.player_faction)

func setupOrbit(planet, orbit):
    orbital_pos = orbit

