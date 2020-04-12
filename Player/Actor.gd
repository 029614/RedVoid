extends KinematicBody2D


""" -------- DECLARATION -------- """
onready var bodies = get_parent().get_node("Navigation2D/Bodies")
onready var engine = get_parent()
onready var last_position = get_position()
onready var fuel_gauge = $CanvasLayer/HUD/Vitals/FuelGauge

var explosion = preload("res://Assets/Particles/Explosion.tscn")
var projectile = preload("res://Assets/Particles/Projectile.tscn")

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var orbital_pos
var orbit = {}
var planet
var zoom = Vector2()

#Ship
onready var thrust = 2000
var mass = 10
export var fuel = 5000
var fuel_cap = 5000
var blink_speed = 5
var red_alpha = 130
onready var gun_coords = $GunCoords

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
var v_dir = Vector2()

#speed managers
export (int) var speed = 500
export (float) var rotation_speed = 2
var current_speed = 0
var max_speed = 99999
var speed_modifier = 1

#flags
var _orbiting = false
var _low_fuel = false
var _no_fuel = false
var _no_ammo = true
var _no_missile = true
var _no_bomb = true
var _zoom_enabled = true
var _map_view = false
var _local_view = false
var _player_is_landed = false
var _heat_shield = false
var _after_burner = false



""" -------- FUNCTIONS -------- """
#initialize variables
func _ready():
    
    #Connecting signals and presetting flags
    Global.connect("player_landed", self, "land")
    Global.connect("player_arrival", self, "setupOrbit")
    Global.connect("player_died", self, "destruct")
    Global._process_player_movement = true
    
    #Other start up related shit
    acceleration = thrust/mass
    print("acceleration: ", acceleration)

func get_input(delta):
        
    #Directional Inputs
    if _player_is_landed == false and _orbiting == false:
        rotation_dir = 0
        if Input.is_action_pressed('ui_right'):
            rotation_dir += 1 
        if Input.is_action_pressed('ui_left'):
            rotation_dir -= 1
        if Input.is_action_pressed('ui_down'):
            pass
        if Input.is_action_pressed('ui_up') and fuel >= 0:
            #After Burner
            if _after_burner == true:
                speed_modifier = 10
                $Sprite/AB1.set_emitting(true)
                $Sprite/AB2.set_emitting(true)
            elif _after_burner == false:
                speed_modifier = 1
                $Sprite/AB1.set_emitting(false)
                $Sprite/AB2.set_emitting(false)
        
            #Changing the sprite to the one with engine plumes
            if $Sprite/Particles2D.is_emitting() == false:
                $Sprite/Particles2D.restart()
                $Sprite/Particles2D.set_emitting(true)
            
            #Input Movements
            current_speed = velocity.length()
            velocity += Vector2(1, 0).rotated(rotation).normalized() * (acceleration * speed_modifier) * delta
            velocity = velocity.clamped(max_speed)
            fuel -= 1 * (speed_modifier * 2)
                
        
        
        else:
            
            #Changing the sprite back to the one without engine plumes
            $Sprite/Particles2D.set_emitting(false)
            $Sprite/AB1.set_emitting(false)
            $Sprite/AB2.set_emitting(false)
            _after_burner = false

func _physics_process(delta):
    if Global._play == true:
        get_input(delta)
        get_gravity(delta)
        rotation += rotation_dir * rotation_speed * delta
        if _orbiting == true:
            global_position = orbital_pos.get_global_position()
            look_at(planet.get_global_position())
        
        #For when you land on a planet
        if Global._process_player_movement == true and _player_is_landed == true:
            velocity = Vector2(lerp(velocity.x, 0, friction), lerp(velocity.y, 0, friction))
            velocity = move_and_slide(velocity)
            look_at(planet.global_position)
            rotation += 3.14
            
        #For flying around normally
        elif Global._process_player_movement == true and _player_is_landed == false:
            velocity = move_and_slide(velocity)
        
        #Fuel Gauge
        if _low_fuel == true:
            if red_alpha == 50:
                blink_speed = -5
            elif red_alpha == 180:
                blink_speed = 5
            fuel_gauge.set_self_modulate(Color8(253,50,40,red_alpha-blink_speed))
            fuel_gauge.get_node("Label").set_self_modulate(Color8(253,50,40,red_alpha-blink_speed))
            red_alpha -= blink_speed
        
        #Map
        if _map_view == true and $ChaseCamera.zoom <= Vector2(12,12):
            if $ChaseCamera.zoom > Vector2(12,12):
                $ChaseCamera.zoom = Vector2(12,12)
            $ChaseCamera.zoom += Vector2(.2,.2)
        elif _local_view == true and $ChaseCamera.zoom > zoom:
            $ChaseCamera.zoom -= Vector2(.2,.2)
        elif _local_view == true and $ChaseCamera.zoom == zoom:
            _local_view = false
        
        if $ChaseCamera.zoom < Vector2(10,10):
            $CanvasLayer/MapIcon.hide()
        elif $ChaseCamera.zoom >= Vector2(10,10):
            $CanvasLayer/MapIcon.show()
        $CanvasLayer/MapIcon.set_global_rotation(get_global_rotation() + deg2rad(90))
        
        if _player_is_landed == true:
            fuel += 10
            fuel = clamp(fuel, 0, fuel_cap)
            print("refueling - ", fuel/float(fuel_cap)*100)
        
        #Heat shield
        if planet:
            if global_position.distance_to(planet.global_position) < 400 and current_speed > 125 and _heat_shield == false:
                _heat_shield = true
                $HeatShield/HeatShield2/Particles2D.set_emitting(true)
            elif global_position.distance_to(planet.global_position) > 400 and _heat_shield == true or current_speed < 125 and _heat_shield == true:
                _heat_shield = false
                $HeatShield/HeatShield2/Particles2D.set_emitting(false)
            else:
                pass
        if _heat_shield == true:
            $HeatShield.look_at(velocity/delta) 
        
        updateGauge()
        
        #Player Location
        if global_position.x < Global.map_origin.x:
            global_position.x += Global.map_limit.x
        elif global_position.x > Global.map_limit.x:
            global_position.x -= Global.map_limit.x
        if global_position.y < Global.map_origin.y:
            global_position.y += Global.map_limit.y
        elif global_position.y > Global.map_limit.y:
            global_position.y -= Global.map_limit.y
        

func _input(event):
    if Global._play == true:
        
        #Weapons
        if _player_is_landed == false and Input.is_action_just_pressed("weapons"):
            Global.emit_signal("torpedo_request", self)
    
        #Orbit
        if Global._player_in_orbit == true and _orbiting == false and Input.is_action_just_pressed("orbit"):
            orbit(orbit, planet)
        elif _orbiting == true and Input.is_action_just_pressed("orbit"):
            _orbiting = false
        
        #Lift Off
        if _player_is_landed == true and Input.is_action_just_pressed("weapons"):
            print("player launch")
            velocity += Vector2(1, 0).rotated(rotation).normalized()*launch_speed
            velocity = move_and_slide(velocity)
            _player_is_landed = false
        
        #Camera Zoom
        if Input.is_action_pressed("zoom_in") and _zoom_enabled == true:
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x - .1, $ChaseCamera.get_zoom().y - .1))
        if Input.is_action_pressed("zoom_out") and _zoom_enabled == true:
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x + .1, $ChaseCamera.get_zoom().y + .1))
        
        #Map
        if Input.is_action_just_pressed("map") and _map_view == false:
            zoom = $ChaseCamera.zoom
            _map_view = true
        elif Input.is_action_just_pressed("map") and _map_view == true:
            _map_view = false
            _local_view = true
        
        #After Burner
        if Input.is_action_pressed("AfterBurner"):
            _after_burner = true
        elif Input.is_action_just_released("AfterBurner"):
            _after_burner = false
        

func get_gravity(delta):
    for body in bodies.get_children():
        velocity += ( body.mass / (body.position.distance_to(self.position)) * self.position.direction_to(body.position) ) * delta

func land(planet):
    _player_is_landed = true
    print("player is landed on: ", planet)
    Global.emit_signal("capture_planet", Global.player_faction)

func setupOrbit(orbit_data, target):
    planet = target
    orbit = orbit_data
    print("Orbital Coordinates Received")
    
func orbit(orbit, planet):
    var p_pos = get_global_position()
    var obd = {} # Orbit By Distance. Contains a list of orbits. orbit reference:distance from ship
    for pos in orbit:
        if orbit.get(pos) == false:
            obd[pos] = pos.get_global_position().distance_to(p_pos)
    var s = obd.values()
    s.sort()
    for key in obd:
        if obd[key] == s[0]:
            orbital_pos = key
    _orbiting = true
    print("all code has run")

func updateGauge():
    #Fuel Gauge
    if fuel > 0:
        fuel_gauge.set_value((fuel/float(fuel_cap))*100)
        if fuel/float(fuel_cap)*100 <= 25 and fuel/float(fuel_cap)*100 > 0:
            fuel_gauge.set_self_modulate(Color8(253,50,40,130))
            fuel_gauge.get_node("Label").set_self_modulate(Color8(253,50,40,130))
            fuel_gauge.get_node("Label").set_text("Low Fuel!")
            _low_fuel = true
        else:
            fuel_gauge.set_self_modulate(Color8(54,246,0,109))
            fuel_gauge.get_node("Label").set_self_modulate(Color8(54,246,0,109))
            fuel_gauge.get_node("Label").set_text("Fuel")
            _low_fuel = false
            _no_fuel = false
    else:
        _low_fuel = false
        _no_fuel = true
        fuel_gauge.set_self_modulate(Color8(253,50,40,0))
        fuel_gauge.get_node("Label").set_self_modulate(Color8(243,192,19,202))
        fuel_gauge.get_node("Label").set_text("-No Fuel-")

func playerLog(string):
    pass

func destruct():
    $Sprite.hide()
    var e = explosion.instance()
    add_child(e)
    e.get_node("Particles2D").set_emitting(true)


    

