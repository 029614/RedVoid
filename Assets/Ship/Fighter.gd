extends KinematicBody2D

onready var bodies = get_parent().get_node("Navigation2D/Bodies")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var target = null
var origin = Vector2()
var travel_distance = 0

#Ship
onready var thrust = 2000
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
export (float) var rotation_speed = 2
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
var states = ["travel", "landing", "launching", "combat", "patrol", "docked", "decelerating", "accelerating"]
var state = "patrol"


#pid
var past_error = [0,0,0,0,0]
var integral_step = 0.1
var integral_timer = null
var process_variable = Vector2(1,0)
var kI = 0
var I = .02 
var maxI = .5 
var P = 2.75 
var D = 1.75 
var do_pid=1
var lookat = Vector2(1, 0)



"""Fighter Agent"""
func _ready() -> void:
    acceleration = thrust/mass
    rads_per_sec = 6.283185*rps
    
    integral_timer = Timer.new()
    add_child(integral_timer)
    integral_timer.connect("timeout",self,"_integral_timer_timeout")
    integral_timer.set_timer_process_mode(0)
    integral_timer.set_one_shot(false)
    integral_timer.start(integral_step)
    

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


func pid_proportion(K, error=0):
    return (error*K)

func pid_integral(K, error):
    
    return (K*error) 

func pid_derivative(delta, error):
    pass

func average(a):
    var s = 0.0
    for i in a:
        s+=i
    s=s/a.size()
    return s
        


func _integral_timer_timeout():
    do_pid=1

func pid(delta):
    
    var sp = (target).angle_to_point(self.global_position) #setpoint (desired normalized velocity vector, or angle)
    #var pv = process_variable.angle() #process variable angle
    var v = velocity.normalized()
    var td = self.global_position.distance_to(target)
    var pv = (global_position+v*td).angle_to_point(self.global_position)
    
    var d = self.global_position.direction_to(target) #direction to target
    
    
    var error = wrapf(sp-pv, -3.14159265, 3.14159265)
    
    var pD=P*error
    kI = kI+error
    var kI2 = clamp(kI*I, -maxI, maxI)
    var kD = D * (past_error[0] - error)
    #var kD = D * 0
    past_error.pop_back()
    past_error.push_front(error)
    
    var total = clamp(pD+kI2+kD, -3.12, 3.12)
    var r = v.rotated(total)
    var rot = Vector2(1, 0).rotated(rotation).normalized()
    #target_balance = rot.dot((target-self.global_position).normalized()) 
    #target_side = rot.rotated(deg2rad(90)).dot((target-self.global_position).normalized()) 
    
    
    #var RvF = 2 * (d.dot(process_variable)) * d - process_variable #process_variable mirrored across the line that is between the target and the ship

    
    #var current_trajectory = global_position.angle_to_point(global_position+velocity.normalized()*td)
    
    var velocity_balance = process_variable.normalized().dot((target-self.global_position).normalized()) 
    lookat = self.global_position + r*td
    if velocity_balance <= 0.0:
        lookat = target
        kI = 0
        kD = 0
        
    var lookat_balance = rot.dot((lookat-self.global_position).normalized()) 
    var lookat_side = rot.rotated(deg2rad(90)).dot((lookat-self.global_position).normalized()) 
    
    if lookat_balance < .999: #target is not directly in front of ship
        if lookat_side < 0: #target is on left
            var ramt = rads_per_sec*delta*-1
            print("Rotate left: ", ramt)
            #rotate(clamp(rads_per_sec*delta*-1, -1*abs(r), abs(r)))
            rotate(ramt)
        elif lookat_side > 0: #target is on right
            var ramt = rads_per_sec*delta
            #rotate(clamp(rads_per_sec*delta, -1*abs(r), abs(r)))
            print("Rotate right: ", ramt)
            rotate(rads_per_sec*delta)
            #rotate(rads_per_sec*delta)
    
    print( " sp: ",sp, " pv: ",pv, " error: ", error, " pD: ",pD," kI: ",kI, " kI2: ",kI2, " kD: ",kD, " total: ",total, " r: ",r," rot: ",rotation, " look: ",lookat, " target: ",target)


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
    var angto = (target).angle_to_point(self.global_position)
    process_variable = (g+tgrav + velocity) #direction of velocity plus gravity PURPLE
    
    if do_pid:
        pid(delta)
        do_pid = 0
        
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
