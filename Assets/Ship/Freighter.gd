extends KinematicBody2D

onready var bodies = get_parent().get_node("Navigation2D/Bodies")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var target = Vector2()
var target_radius = 1
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
var rps = .15
var rads_per_sec = 0

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 2
var current_speed = 0
var max_speed = 99999
var docking_speed = 1

#flags
var _traveling = false

#navigation
var desired_rotation = 0
var desired_velocity = Vector2(0, 0)
var destination = Vector2(0, 0)
var target_side = 0 #( <0 is left, >0 is right)
var target_balance = 0 #( <0 is behind, >0 is in front)

#states
var states = ["traveling", "landing", "launching", "combat", "patrol", "docked", "decelerating", "accelerating"]
var state = "traveling"
var objectives = ["intercept", "engage", "defend", "travel", "escort"]
var objective = "travel"

#pid
var past_error = [0,0,0,0,0]
var integral_step = 0.1
var integral_timer = null
var process_variable = Vector2(1,0)
var kI = 0
var I = .01
var maxI = 1
var P = 2.7
var D = 4.0
var do_pid=1
var lookat = Vector2(1, 0)
var speed_direction = 1


"""Freighter Agent"""
func _ready() -> void:
    acceleration = thrust/mass
    rads_per_sec = 6.283185*rps
    print("rads_per_sec: ", rads_per_sec)
    
    integral_timer = Timer.new()
    add_child(integral_timer)
    integral_timer.connect("timeout",self,"_integral_timer_timeout")
    integral_timer.set_timer_process_mode(0)
    integral_timer.set_one_shot(false)
    integral_timer.start(integral_step)

func navigate():
    var td = global_position.distance_to(target)-target_radius
    var tof = Global.time_of_flight( travel_distance - td,
        self.global_position.distance_to(target), acceleration)
    travel_distance = td
    var ttd = Global.time_to_decelerate(velocity.length(), acceleration)
    var ttr = (1.0/rps)*.5
    if tof < (ttd + ttr * 1.05):
        if velocity.length() > docking_speed:
            decelerate()
        elif velocity.length() < docking_speed:
            accelerate()
    else:
        accelerate()
        
        
func decelerate():
    state = "decelerating"
    speed_direction = -1
    #kI = 0
    #past_error = [0,0,0,0,0]
    
func accelerate():
    state = "accelerating"
    speed_direction = 1
    #kI = 0
    #past_error = [0,0,0,0,0]

    
func time_to_rotate(rps, current_rotation, desired_rotation):
    print("current_rotation: ", current_rotation, " desired_rotation: ", desired_rotation, 
        " time_to_rotate: ", abs(desired_rotation - current_rotation) / rads_per_sec)
    return abs((desired_rotation - current_rotation) / rads_per_sec)
    
func _integral_timer_timeout():
    navigate()
    do_pid=1
    
func pid():
    var sp = (target).angle_to_point(self.global_position) #setpoint (desired normalized velocity vector, or angle)
    var v = velocity.normalized()
    var td = self.global_position.distance_to(target)
    var pv = (global_position+v*td).angle_to_point(self.global_position)
    var d = self.global_position.direction_to(target) #direction to target
    
    var error = wrapf(sp-pv, -3.14159265, 3.14159265)
    
    var pD=P*error
    kI = kI+error
    var kI2 = clamp(kI*I, -maxI, maxI)
    var kD = D * (past_error[0] - error)
    past_error.pop_back()
    past_error.push_front(error)
    
    var total = clamp(pD+kI2+kD, -3.12, 3.12)
    
    var r = (v).rotated(total*speed_direction)

    var velocity_balance = process_variable.normalized().dot(((target)-self.global_position).normalized()) 
    if velocity_balance <= 0.0:
        if speed_direction == 1:
            lookat = target
        else: 
            lookat = self.global_position + ((self.global_position-target))
        kI = 0
        kD = 0
    else:
        lookat = self.global_position + ((r * td))
        
    var rot = Vector2(1, 0).rotated(rotation).normalized()
    var lookat_balance = rot.dot((lookat-self.global_position).normalized()) 
    var lookat_side = rot.rotated(deg2rad(90)).dot((lookat-self.global_position).normalized()) 
    
    if lookat_balance < .999: #target is not directly in front of ship
        if lookat_side < 0: #target is on left
            rotate(rads_per_sec*integral_step*-1*speed_direction)
            print("rotate left: ", rads_per_sec*integral_step*-1, ", ", lookat_side)
        elif lookat_side > 0: #target is on right
            rotate(rads_per_sec*integral_step*speed_direction)
            print("rotate right: ", rads_per_sec*integral_step, ", ", lookat_side)
    
    #print( " sp: ",sp, " pv: ",pv, " error: ", error, " pD: ",pD," kI: ",kI, " kI2: ",kI2, " kD: ",kD, " total: ",total, " r: ",r," rot: ",rotation, " look: ",lookat, " target: ",target, " sd: ",speed_direction)
    
    #print( " error: ", error, " total: ",total, " r: ",r," rot: ",rotation, " look: ",lookat, " target: ",target, " sd: ",speed_direction)
    
    
func update_movement(delta):
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
        

func get_gravity(delta):
    var g = Vector2(0,0)
    var t = Vector2(0,0)
    for body in bodies.get_children():
        if body.position == target:
            t = ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
        else:
            g += ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
    return [g, t]      
    
      
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    var mp = get_parent().position #position of Main
    var gt = get_gravity(delta)
    var g = gt[0] #gravity of all planets except target
    var tgrav = gt[1] #gravity of target
    var angto = (target).angle_to_point(self.global_position)
    process_variable = (g+tgrav + velocity) #direction of velocity plus gravity PURPLE
    
    if do_pid:
        pid()
        do_pid = 0
    
    velocity += (g+tgrav) * delta
    update_movement(delta)
    velocity = move_and_slide(velocity)


# Pathfinding
func calculatePath(origin, target):
    pass

# Behaviors
func goTo(body):
    target = body.global_position
    target_radius = body.planet_radius
    print("target, targetradius: ", target,", ",target_radius)
    origin = self.position
    travel_distance = self.position.distance_to(target)
    _traveling = true
    self.accelerate()

func orbit(body):
    pass

func runFrom(body):
    pass


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

