extends Node

var faction = null

#various information for landing and capturing
var planet = null
var orbit = null
var frame_count = 0


#input and direction
onready var ship = get_node("../..")

#navigation
var desired_rotation = 0
var desired_velocity = Vector2(0, 0)
var destination = Vector2(0, 0)
var travel_distance = 0
var target = null
var target_side = 0 #( <0 is left, >0 is right)
var target_balance = 0 #( <0 is behind, >0 is in front)
var station = null #where this ship is stationed, or the ship it is escorting

#personal attributes
var aggression = 5 # an integer betwwen 1 and 10
onready var flee_proximity = (11-aggression) * 200 # how close a stronger enemy approaches before this pilot flees
onready var engage_proximity = aggression * 200 # how close an equal strength enemy approaches before this pilot engages


#states
var states = ["traveling", "landing", "launching", "combat", "docked", "decelerating", 
        "accelerating", "escorting", "orbiting"]
        
var state = "traveling"

var objectives = ["intercept", "engage", "defend", "travel", "escort", "patrol", "explore", "despawn", "refuel", "retreat"]
var objective = "intercept"

var combat_styles = ["kamikaze", "circle", "tail"]
var combat_style = ["tail"]


#pid
var past_error = [0,0,0,0,0]
var pid_interval = 0.05
onready var pid_timer = Timer.new()
var kI = 0
var I = .05
var maxI = 1
var P = 1
var D = 3
var do_pid=1
onready var intercept_point = ship.global_position
#var last_pid_time = 0

#system status
var status_interval = 1
onready var status_timer = Timer.new()
var do_status = 1

var speed_direction = 1 # 1 to accelerate, -1 to decelerate
var lookat = Vector2(1, 0) #the point in space the ship should be looking at

var focus_angle = 0 #the angle that the ship should be facing

#how near to focus_angle before pilot will accelerate
var acceleration_window = deg2rad(10) 


func _ready() -> void:
    ship.pilot = self
    intercept(get_node("/root/NewMain/Factions/Faction1/Scouts/ScoutShip"))
    #goTo(get_node("/root/NewMain/Navigation2D/Bodies/Planet2"))
    
    add_child(pid_timer)
    pid_timer.connect("timeout",self,"_pid_timer_timeout")
    pid_timer.set_timer_process_mode(0)
    pid_timer.set_one_shot(false)
    pid_timer.start(pid_interval)
    
    add_child(status_timer)
    status_timer.connect("timeout",self,"_status_timer_timeout")
    status_timer.set_timer_process_mode(0)
    status_timer.set_one_shot(false)
    status_timer.start(pid_interval)

func _status_timer_timeout():
    do_status=1    

func _pid_timer_timeout():
    if objective == "intercept":
        intercept_pid()
    elif objective == "travel":
        navigate_pid()
    do_pid=1    
 
func goTo(d):
    destination = d
    state = "traveling"
    
func engage(t):
    target = t
    state = "combat"
    objective = "engage"
    
func defend(s): # defend a body
    station = s # a body to defend
    state = "traveling"
    objective = "defend"
    
func escort(e): # escort a ship
    station = e # a ship to escort
    state = "traveling"
    objective = "escort"
    
func patrol(s): #patrol a sector
    station = s # a sector to patrol
    state = "traveling"
    objective = "patrol"
    
func intercept(t): # intercept a target
    target = t
    state = "traveling"
    objective = "intercept"
    
func explore(s): # intercept a target
    station = s # a sector to explore
    state = "traveling"
    objective = "explore"
    
func retreat():
    state = "combat"
    objective = "retreat"
    destination = locateNearestBase()

func refuel():
    objective = "refuel"
    goTo(locateNearestBase())
        
func decelerate():
    state = "decelerating"
    speed_direction = -1
    
func accelerate():
    state = "accelerating"
    speed_direction = 1

     
func intercept_pid():
    var td = ship.global_position.distance_to(target.global_position)
    
    var tof_v = travel_distance - td
    var tof = Global.time_of_flight( tof_v,
        ship.global_position.distance_to(target.global_position), ship.acceleration)
        
    intercept_point = target.global_position + target.velocity*tof
    td = ship.global_position.distance_to(intercept_point)
    
    tof = Global.time_of_flight( tof_v,
        td, ship.acceleration)
        
    travel_distance = td
    var ttd = Global.time_to_decelerate(ship.velocity.length(), ship.acceleration)
    #var ttd = Global.time_to_match_velocity(ship.velocity, ship.acceleration, target.velocity)
    var ttr = (1.0/ship.rps)*.5
    
    print(" td: ",td, " tof: ",tof, " ttd: ",ttd, " ttr: ",ttr)
    
    if tof < ((ttd + ttr) * .9):
        #if ship.velocity.length() > target.velocity.length()*1.01:
        decelerate()
        #elif ship.velocity.length() < target.velocity.length()*.99:
        #    accelerate()
    else:
        if ship.velocity.length() < ship.max_speed:
            accelerate()
            
    
func navigate_pid():
    var td = ship.global_position.distance_to(destination.global_position)
    var tof = Global.time_of_flight( travel_distance - td,
        ship.global_position.distance_to(destination.global_position), ship.acceleration)
        
    travel_distance = td
    var ttd = Global.time_to_decelerate(ship.velocity.length(), ship.acceleration)
    var ttr = (1.0/ship.rps)*.5
    if tof < ((ttd + ttr) * .9):
        if ship.velocity.length() > ship.docking_speed:
            decelerate()
        elif ship.velocity.length() < ship.docking_speed:
            accelerate()
    else:
        accelerate()
        
          
func rotation_pid():
    var sp = (target.global_position).angle_to_point(ship.global_position) #setpoint (desired normalized velocity vector, or angle)
    var v = ship.velocity.normalized()
    var td = ship.global_position.distance_to(target.global_position)
    var pv = (ship.global_position+v*td).angle_to_point(ship.global_position)
    
    var error = wrapf(sp-pv, -Global.pi, Global.pi)
    
    #var d = ship.global_position.direction_to(getTargetPos()) #direction to target
    
    var pD=P*error
    kI = kI+error
    var kI2 = clamp(kI*I, -maxI, maxI)
    var kD = D * (past_error[0] - error)
    past_error.pop_back()
    past_error.push_front(error)
    
    
    var r = v.rotated(speed_direction * clamp(pD+kI2+kD, -3.12, 3.12))
    var velocity_balance = v.dot(((target.global_position)-ship.global_position).normalized()) 
    
    if velocity_balance <= 0.0:
        if speed_direction == 1:
            lookat = target.global_position
        else: 
            lookat = ship.global_position + ((ship.global_position-target.global_position))
        kI = 0
        #kD = 0\
    elif objective == "intercept":
        lookat = intercept_point
    else:
        lookat = ship.global_position + ((r * td))
        
    var rot = Vector2(1, 0).rotated(ship.rotation).normalized()
    var lookat_balance = rot.dot((lookat-ship.global_position).normalized()) 
    var lookat_side = rot.rotated(deg2rad(90)).dot((lookat-ship.global_position).normalized()) 
    
    if lookat_balance < .99: #target is not directly in front of ship
        if lookat_side < 0: #target is on left
            #ship.rotate(ship.rads_per_sec*pid_interval*-speed_direction)
            ship.rotateShip(pid_interval, -speed_direction, ship.rads_per_sec*pid_interval*-speed_direction)
        elif lookat_side > 0: #target is on right
            #ship.rotate(ship.rads_per_sec*pid_interval*speed_direction)
            ship.rotateShip(pid_interval, speed_direction, ship.rads_per_sec*pid_interval*speed_direction)
            
    focus_angle = lookat.angle_to_point(ship.global_position)
    print("lk: ",lookat, " lkang: ",lookat.angle_to_point(ship.global_position),
        " sp_dir: ",speed_direction, " vel_bal: ",velocity_balance, " lk_bal: ",lookat_balance, 
        " shp_pos: ", ship.global_position, " tar_pos: ", target.global_position)


# Pathfinding
func calculatePath(origin, target):
    pass
    
func rotDirection(angle1, angle2):
    var direction = wrapf(angle1 - angle2, -Global.pi, Global.pi)
    print("rotdirection: ", angle1," , ",angle2, " , ",direction)
    if direction < 0:
        return -1
    elif direction > 0:
        return 1
    else:
        return 0
 
func updateShipStatus():
    ship.estimateStrength()
    var nearby_objects = ship.proximityScan() #[enemies, allies, bodies]
    if objective != "refuel":
        checkFuelStatus()
    if state == "combat":
        var combat_advantage = assessCurrentEngagement(nearby_objects)
        if combat_advantage < -aggression:
            objective = "retreat"
            destination = locateNearestBase()
    
   
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    var aw = [wrapf(focus_angle - acceleration_window, -Global.pi, Global.pi), 
        wrapf(focus_angle + acceleration_window, -Global.pi, Global.pi)]
    print("aw: ",aw, " focusangle: ",focus_angle, " accel win: ", acceleration_window, " ship rot: ",ship.rotation)
    if rotDirection(ship.rotation, aw[0]) >= 0 and rotDirection(ship.rotation, aw[1]) <= 0:
        ship.accelerate(delta)
    else:
        ship.glide()
        
    
    if do_pid:
        rotation_pid()
        do_pid = 0
        
    if do_status:
        #updateShipStatus()
        do_status = 0
        
        
#shuttle
func setPath(waypoints):
    pass
    

func _baseDestroyed(base):
    if base == self.home_base:
        var r = locateNearestBase()
        objective = "despawn"
        goTo(r)
        
func locateNearestBase():
    var nearest_base = null
    for base in faction.bases:
        if not nearest_base:
            nearest_base = base
        else:
            if base.global_location.distance_to(ship.global_location) < nearest_base.global_location.distance_to(ship.global_location):
                nearest_base = base

func checkFuelStatus():
    if ship.fuel <= ship.fuel_cap * ((11-aggression) *.035 ):
        refuel()
        
func attachToFleet(fleet):
    pass
    
func assessCurrentEngagement(nearby_objects): # [nearby_enemies, nearby_bodies, nearby_allies]
    var opponent_strength = 0
    var ally_strength = 0
    for e in nearby_objects[0]:
        opponent_strength += e.strength()
    for a in nearby_objects[2]:
        ally_strength += a.strength()
    return ship.strength + ally_strength - opponent_strength
