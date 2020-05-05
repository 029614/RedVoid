extends KinematicBody2D

onready var bodies = get_parent().get_node("Bodies")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var target = Vector2()
var origin = Vector2()
var travel_distance = 0
var orbit
var orbit_speed
var current_orbit

#Ship
onready var thrust = 4000
var mass = 100
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
var _traveling = false
var _orbiting = false
var _orbit_stable = false


"""Freightor Agent"""

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    acceleration = thrust/mass

func get_gravity(delta):
    var g = Vector2(0,0)
    var t = Vector2(0,0)
    for body in bodies.get_children():
        if body.position == target:
            t = ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
        else:
            g += ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
    return [g, t]
    
func get_input(delta):
    #Directional Inputs
    if self.position.distance_to(target) < travel_distance / 2:
        pass
    if _traveling == true and fuel >= 0:
        
        #Changing the sprite to the one with engine plumes
        $Sprite.hide()
        $Flying.show()
        
        #Input Movements
        current_speed = velocity.length()
        velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
        velocity = velocity.clamped(max_speed)
        fuel -= 1
        
    if _orbiting == true and _orbit_stable == false:
        if current_orbit > orbit:
            velocity -= Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
        elif current_orbit < orbit:
            velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
        
        
    else:
        
        #Changing the sprite back to the one without engine plumes
        $Sprite.show()
        $Flying.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    var mp = get_parent().position #position of Main
    var gt = get_gravity(delta)
    var g = gt[0] #gravity of all planets except target
    var tgrav = gt[1] #gravity of target
    var d = self.global_position.direction_to(mp+target) #direction to target
    var tang = d.tangent()
    var Rv = (g+tgrav + velocity).normalized() #direction of velocity plus gravity
    var RvF = (Rv*-1).reflect(tang)
    var td = self.global_position.distance_to(mp+target)
    
    var lookat = self.global_position+((RvF)*td)

    #print("td: ", "d: ", "Rv: ", "RvF: ", "lookat: ", "velocity: ", "g: ", "tang: ", td, d, Rv, RvF, lookat, velocity, g+tgrav, tang)

    self.look_at(lookat)
    velocity += (g+tgrav) * delta
    get_input(delta)
    velocity = move_and_slide(velocity)


# Behaviors
func goTo(body):
    target = body.position
    origin = self.position
    travel_distance = self.position.distance_to(target)
    _traveling = true

func orbit(body):
    target = body
    orbit = 0 # distance from the planets center sqrt((radius.pow(2) + mass.pow(2)))
    orbit_speed = 0 # speed at which to maintain a stable orbit. (maintain a 1/1 Vector ratio)

func runFrom(body):
    pass


# Pathfinding
func calculatePath(origin, target):
    pass
