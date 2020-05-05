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
var rps = .5
var rads_per_sec = 0

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 2
var current_speed = 0
var max_speed = 99999

#flags
var _traveling = false

#navigation
var desired_rotation = 0
var desired_velocity = Vector2(0, 0)
var destination = Vector2(0, 0)
var target_side = 0 #( <0 is left, >0 is right)
var target_balance = 0 #( <0 is behind, >0 is in front)

#properties
var faction = null
export (Color) var ship_color = Color(1,1,1,1)


"""Freighter Agent"""
func _ready() -> void:
    acceleration = thrust/mass
    rads_per_sec = 6.283185*rps
    $Sprite/Sprite.modulate = ship_color


func apply_gravity(delta):
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
    #print("current_rotation: ", current_rotation, " desired_rotation: ", desired_rotation, 
    #    " time_to_rotate: ", abs(desired_rotation - current_rotation) / rads_per_sec)
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
    if _traveling == true and fuel >= 0:
        
        #Changing the sprite to the one with engine plumes
        if $Engines/Particles2D.is_emitting() == false:
            $Engines/Particles2D.restart()
            $Engines/Particles2D.set_emitting(true)
            $Engines/Particles2D2.restart()
            $Engines/Particles2D2.set_emitting(true)
        
        #Input Movements
        current_speed = velocity.length()
        velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta
        velocity = velocity.clamped(max_speed)
        fuel -= 1
        
        
    else:
        
        #Changing the sprite back to the one without engine plumes
            $Engines/Particles2D.set_emitting(false)
            $Engines/Particles2D2.set_emitting(false)

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
    var gt = apply_gravity(delta)
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



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Getters and Setters @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# movement ------------------------------------------
func set_max_speed(new_max_speed: int):
    pass

func get_max_speed():
    pass

func get_current_speed():
    pass

func get_acceleration():
    pass

func set_thrust(new_thrust: float):
    pass

func get_thrust():
    pass

func set_mass(new_mass: int):
    pass

func get_mass():
    pass

func get_gravity():
    pass

func get_velocity():
    pass



#Consumables ------------------------------------------------
func set_cannon_ammo(ammo: int):
    pass

func get_cannon_ammo():
    pass

func set_cannon_ammo_max(max_ammo: int):
    pass

func get_cannon_ammo_max():
    pass



func set_missile_count(count: int):
    pass

func get_missile_count():
    pass

func set_missile_count_max(max_count: int):
    pass

func get_missile_count_max():
    pass



func set_bomb_count(count: int):
    pass

func get_bomb_count():
    pass

func set_bomb_count_max(max_count: int):
    pass

func get_bomb_count_max():
    pass



#Vitals ------------------------------------------------
func set_shields(shields: int):
    pass

func get_shields():
    pass

func set_max_shields(max_shields: int):
    pass

func get_max_shields():
    pass



func set_fuel(fuel: int):
    pass

func get_fuel():
    pass

func set_max_fuel(max_fuel: int):
    pass

func get_max_fuel():
    pass
