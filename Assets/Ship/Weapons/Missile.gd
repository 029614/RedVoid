extends KinematicBody2D

onready var bodies = get_parent().get_node("Navigation2D/Bodies")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var target = null
var origin = Vector2()
var travel_distance = 0

#Ship
onready var thrust = 20000
var mass = 10
export var fuel = 250000

#Ship Components
var fuel_tank_tier = 1 #1-3
var engine_tier = 1 #1-3
var shields_tier = 1 #0-3
var cargo_tier = 0 #1-3
var weapons_tier = 1 #0-3

#launcher
var launch_speed = 100

#physics
var acceleration = 0
var friction = 1
var rps = 1
var rads_per_sec = 0

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 1
export (Color) var enemy_color = Color(1,1,1,1)
var current_speed = 0
var max_speed = 99999

#flags
var _traveling = false

#navigation
var desired_rotation = 0
var desired_velocity = Vector2(0, 0)
var destination = Vector2(0, 0)
var target_ship = null
var target_side = 0 #( <0 is left, >0 is right)
var target_balance = 0 #( <0 is behind, >0 is in front)

#states
var states = ["travel", "landing", "launching", "combat", "patrol", "docked"]
var state = "patrol"



"""Fighter Agent"""
func _ready() -> void:
    acceleration = thrust/mass
    rads_per_sec = 6.283185*rps
    #$Sprite/ShipAccent.modulate = enemy_color
    #velocity = get_parent().velocity
    

func get_gravity(delta):
    var g = Vector2(0,0)
    var t = Vector2(0,0)
    for body in bodies.get_children():
        if body.position == target:
            t = ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
        else:
            g += ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
    return [g, t]


func time_of_flight(velocity,distance,accel): #all values are floats
    return (sqrt(velocity*velocity+2*acceleration*distance) - velocity) / acceleration
    
func time_to_rotate(rps, current_rotation, desired_rotation):
    print("current_rotation: ", current_rotation, " desired_rotation: ", desired_rotation, 
        " time_to_rotate: ", abs(desired_rotation - current_rotation) / rads_per_sec)
    return abs((desired_rotation - current_rotation) / rads_per_sec)

func turn():
    pass
    
func accelerate():
    pass
    
func decelerate():
    pass


func update_movement(delta):
    #Directional Inputs
    if self.position.distance_to(target) < travel_distance / 2:
        pass
    if fuel >= 0:
        
        #Changing the sprite to the one with engine plumes
        if $Particles2D.is_emitting() == false:
            $Particles2D.restart()
            $Particles2D.set_emitting(true)
        
        #Input Movements
        current_speed = velocity.length()
        velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
        velocity = velocity.clamped(max_speed)
        fuel -= 1
        
        
    else:
        
        #Changing the sprite back to the one without engine plumes
            $Particles2D.set_emitting(false)

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
    target = get_node("/root/NewMain/Actor").global_position
    var mp = get_parent().position #position of Main
    var gt = get_gravity(delta)
    var g = gt[0] #gravity of all planets except target
    var tgrav = gt[1] #gravity of target
    var d = self.global_position.direction_to(target) #direction to target
    var angto = (target).angle_to_point(self.global_position)
    
    
    var rot = Vector2(1, 0).rotated(rotation).normalized()
    target_balance = rot.dot((target-self.global_position).normalized()) 
    target_side = rot.rotated(deg2rad(90)).dot((target-self.global_position).normalized()) 
    
    

    var Rv = (g+tgrav + velocity) #direction of velocity plus gravity PURPLE
    var RvF = 2 * (d.dot(Rv)) * d - Rv #Rv mirrored across the line that is between the target and the ship

    var td = self.global_position.distance_to(target)
    
    var velocity_balance = Rv.normalized().dot((target-self.global_position).normalized()) 
    var lookat = self.global_position+((RvF)*td)
    if velocity_balance <= 0:
        lookat = target
        
    var lookat_balance = rot.dot((lookat-self.global_position).normalized()) 
    var lookat_side = rot.rotated(deg2rad(90)).dot((lookat-self.global_position).normalized()) 
    
    if lookat_balance < .999: #target is not directly in front of ship
        if lookat_side < 0: #target is on left
            rotate(rads_per_sec*delta*-1)
        elif lookat_side > 0: #target is on right
            rotate(rads_per_sec*delta)
    

    #print("td: ",td, "d: ",d, "Rv: ",Rv, "RvF: ",RvF, "lookat: ",lookat, "velocity: ",velocity, "g: ",g, "angleto: ",angto, ", ",self.rotation, "r2v: ", r2v)

    #var dot1 = (target-self.global_position).normalized().dot(target.normalized())
    #var dotlabel = get_node("/root/Main/CanvasLayer/UI/dot1/Label")
    #dotlabel.set_text(String(dot1))
    
    #self.look_at(lookat)
    velocity += (g+tgrav) * delta
    update_movement(delta)
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
