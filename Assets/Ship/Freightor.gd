extends KinematicBody2D

onready var bodies = get_parent().get_node("Navigation2D/Bodies")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var target = Vector2()
var origin = Vector2()
var travel_distance = 0

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
        
        
    else:
        
        #Changing the sprite back to the one without engine plumes
        $Sprite.show()
        $Flying.hide()

func draw_arrow(arrow, t, mp):
    var d = self.global_position.distance_to(t)
    var v = self.global_position.direction_to(t)
    #var v = t.direction_to(self.global_position)
    #var r = self.global_position.angle_to_point(t)
    var r = t.angle_to_point(self.global_position)
    arrow.scale = Vector2(int(d), 3)
    arrow.set_global_position( self.global_position + ( (d*v)*.5 ) )
    #arrow.set_global_position(t)
    arrow.rotation = r

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    var mp = get_parent().position #position of Main
    var gt = get_gravity(delta)
    var g = gt[0] #gravity of all planets except target
    var tgrav = gt[1] #gravity of target
    var d = self.global_position.direction_to(target) #direction to target
    var angto = (target).angle_to_point(self.global_position)

    var tang = d.tangent()
    var Rv = (g+tgrav + velocity).normalized() #direction of velocity plus gravity
    
    var RvF = (Rv*-1).reflect(tang)
    
    var td = self.global_position.distance_to(target)
    var r2v = Vector2(cos(self.rotation), sin(self.rotation))
    var lookat = self.global_position+((RvF)*td)
    #if td < 200:
    #    lookat = mp+target
    
    draw_arrow(get_node("/root/Main/ship_lookat"), lookat, mp)
    draw_arrow(get_node("/root/Main/ship_gravity"), self.global_position+((g+tgrav)*100), mp)
    

    print("td: ",td, "d: ",d, "Rv: ",Rv, "RvF: ",RvF, "lookat: ",lookat, "velocity: ",velocity, "g: ",g, "angleto: ",angto, ", ",self.rotation, "r2v: ", r2v)

    self.look_at(lookat)
    velocity += (g+tgrav) * delta
    get_input(delta)
    velocity = move_and_slide(velocity)


# Behaviors
func goTo(body):
    target = body.global_position
    origin = self.position
    travel_distance = self.position.distance_to(target)
    _traveling = true

func orbit(body):
    pass

func runFrom(body):
    pass


# Pathfinding
func calculatePath(origin, target):
    pass
