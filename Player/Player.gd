extends Node2D


""" -------- DECLARATION -------- """
onready var bodies = Global.bodies
onready var engine = Global.world
onready var last_position = get_position()
onready var ship = get_parent().get_parent()
onready var faction = ship.get_parent().get_parent()
onready var hud = $CanvasLayer/HUD
onready var fuel_gauge = $CanvasLayer/HUD/Vitals/FuelGauge

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var orbital_pos
var orbit = {}
var planet
var zoom = Vector2()

#Ship
onready var ship_size = ship.ship_size

#launcher
var launch_speed = 100

#physics
var friction = 1
var v_dir = Vector2()

#speed managers
export (int) var speed = 500
var current_speed = 0

#flags
var _weapon_select = "cannon" #Can be cannon, missile or bomb

var weapon_states = ["missiles", "bombs", "cannon"]
var current_weapon = "cannon"
var firing_cannon = false
var cannon_speed = 1
var cannon_ready = true

var camera_states = ["zoomed_in", "zoomed_out", "zooming_in", "zooming_out"]
var camera_state = "zoomed_in"



""" -------- FUNCTIONS -------- """
#initialize variables
func _ready():
    
    #Connecting signals and presetting flags
    ship.pilot = self
    ship.faction = faction
    Global.connect("player_arrival", self, "setupOrbit")
    Global.connect("player_died", self, "destruct")
    Global._process_player_movement = true
    Global.player_registry.append(self)
    $CanvasLayer/HUD.player = self
    $ChaseCamera.zoom = Vector2(2*ship_size,2*ship_size)

func get_input(delta):
    
    rotation_dir = 0
    #Directional Inputs
    if ship.location_state == "free":
        if Input.is_action_pressed('ui_right'):
            rotation_dir += 1 
        if Input.is_action_pressed('ui_left'):
            rotation_dir -= 1
        if Input.is_action_pressed('ui_down'):
            pass
        if Input.is_action_pressed('ui_up') and ship.fuel >= 0:
            
            
            #Input Movements
            current_speed = velocity.length()
            ship.current_speed = velocity.length()
            velocity += Vector2(1, 0).rotated(ship.rotation).normalized() * (ship.acceleration * ship.thrust_modifier) * delta
            velocity = velocity.clamped(ship.max_speed)
            ship.fuel -= 1 * (ship.thrust_modifier * 2)
            ship.animate_engines = true
        else: 
            ship.animate_engines = false
                

func _physics_process(delta):
    if Global._play == true:
        get_input(delta)
        apply_gravity(delta)
        rotation += rotation_dir * ship.rotation_speed * delta
        
        if ship.location_state == "in_orbit":
            ship.global_position = orbital_pos.get_global_position()
            ship.look_at(planet.get_global_position())
            ship.rotation += deg2rad(-90)
            
        #For flying around normally
        elif ship.location_state == "free":
            velocity = ship.move_and_slide(velocity)
        
        elif ship.location_state == "landing":
            print("player has now landed")
            ship.location_state = "on_planet"
        
        #Map
        if camera_state == "zooming_out" and $ChaseCamera.zoom < Vector2(20,20):
            $ChaseCamera.zoom += Vector2(.2,.2)
        elif camera_state == "zooming_out" and $ChaseCamera.zoom > Vector2(20,20):
            $ChaseCamera.zoom = Vector2(20,20)
        elif camera_state == "zooming_out" and $ChaseCamera.zoom == Vector2(20,20):
            camera_state = "zoomed_out"
            
        if camera_state == "zooming_in" and $ChaseCamera.zoom > Vector2(3*ship_size,3*ship_size):
            $ChaseCamera.zoom -= Vector2(.2,.2)
        elif camera_state == "zooming_in" and $ChaseCamera.zoom < Vector2(3*ship_size,3*ship_size):
            $ChaseCamera.zoom = Vector2(3*ship_size,3*ship_size)
        elif camera_state == "zooming_in" and $ChaseCamera.zoom == Vector2(3*ship_size,3*ship_size):
            camera_state = "zoomed_in"
        
        if $ChaseCamera.zoom < Vector2(10,10):
            $CanvasLayer/MapIcon.hide()
        elif $ChaseCamera.zoom >= Vector2(10,10):
            $CanvasLayer/MapIcon.show()
        $CanvasLayer/MapIcon.set_global_rotation(ship.get_global_rotation() + deg2rad(90))
        
        
        updateGauge()
        
        if ship.shields <= 0:
            self.queue_free()
        
    #cannon
    if firing_cannon == true:
        ship.fireControl("cannon")
        

func _input(event):
    if Global._play == true:
        
        #Weapons
        if ship.location_state == "free" and current_weapon == "missile" and Input.is_action_just_pressed("weapons"):
            #Global.emit_signal("torpedo_request", self)
            ship.fireControl("missile")
        if ship.location_state == "free" and current_weapon == "cannon" and Input.is_action_pressed("weapons"):
            firing_cannon = true
        elif ship.location_state == "free" and current_weapon == "cannon" and Input.is_action_just_released("weapons"):
            firing_cannon = false
        
        #Camera Zoom
        if Input.is_action_pressed("zoom_in") and camera_state == "zoomed_in":
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x - .1, $ChaseCamera.get_zoom().y - .1))
        if Input.is_action_pressed("zoom_out") and camera_state == "zoomed_in":
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x + .1, $ChaseCamera.get_zoom().y + .1))
        
        #Map
        if Input.is_action_just_pressed("map") and camera_state == "zoomed_in":
            camera_state = "zooming_out"
        elif Input.is_action_just_pressed("map") and camera_state == "zoomed_out":
            camera_state = "zooming_in"
        
        #After Burner
        if Input.is_action_pressed("AfterBurner"):
            ship.fire_after_burner = true
        elif Input.is_action_just_released("AfterBurner"):
            ship.fire_after_burner = false
        
        #Weapon Select
        if Input.is_action_just_pressed("cannon"):
            weaponSelect(1)
        if Input.is_action_just_pressed("missile"):
            weaponSelect(2)
        if Input.is_action_just_pressed("bomb"):
            weaponSelect(3)
        
        #orbit
        if orbit and planet:
            if Input.is_action_just_pressed("orbit") and ship.location_state == "free":
                orbit(orbit, planet)
                velocity = Vector2()
                ship.velocity = Vector2()
            elif Input.is_action_just_pressed("orbit") and ship.location_state == "in_orbit":
                ship.location_state = "free"
                velocity = Vector2()
                ship.velocity = Vector2()
        
        if ship.location_state == "on_planet" and Input.is_action_just_pressed("ui_up"):
            ship.location_state = "free"
            planet = null
            velocity = Vector2()
            ship.velocity = Vector2()

func apply_gravity(delta):
    for body in Global.bodies:
        velocity += ( body.mass / (body.global_position.distance_to(ship.global_position)) * ship.global_position.direction_to(body.global_position) ) * delta

func setupOrbit(orbit_data, target):
    planet = target
    orbit = orbit_data
    print("Orbital Coordinates Received")
    
func orbit(orbit, planet):
    var p_pos = ship.get_global_position()
    var obd = {} # Orbit By Distance. Contains a list of orbits. orbit reference:distance from ship
    for pos in orbit:
        if orbit.get(pos) == false:
            obd[pos] = pos.get_global_position().distance_to(p_pos)
    var s = obd.values()
    s.sort()
    for key in obd:
        if obd[key] == s[0]:
            orbital_pos = key
    ship.location_state = "in_orbit"
    print("all code has run")

func updateGauge():
    #Fuel Gauge
    if ship.fuel > 0:
        fuel_gauge.set_value((ship.fuel/float(ship.fuel_cap))*100)
        if ship.fuel/float(ship.fuel_cap)*100 <= 25 and ship.fuel/float(ship.fuel_cap)*100 > 0:
            fuel_gauge.set_self_modulate(Color8(253,50,40,130))
            fuel_gauge.get_node("Label").set_self_modulate(Color8(253,50,40,130))
            fuel_gauge.get_node("Label").set_text("Low Fuel!")
        else:
            fuel_gauge.set_self_modulate(Color8(54,246,0,109))
            fuel_gauge.get_node("Label").set_self_modulate(Color8(54,246,0,109))
            fuel_gauge.get_node("Label").set_text("Fuel")
    else:
        fuel_gauge.set_self_modulate(Color8(253,50,40,0))
        fuel_gauge.get_node("Label").set_self_modulate(Color8(243,192,19,202))
        fuel_gauge.get_node("Label").set_text("-No Fuel-")

func playerLog(string):
    pass


func weaponSelect(select):
    if select == 1:
        current_weapon = "cannon"
        $CanvasLayer/HUD/Weapons/VBoxContainer/Missiles/Control.hide()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Bombs/Control.hide()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Guns/Control.show()
    elif select == 2:
        current_weapon = "missile"
        $CanvasLayer/HUD/Weapons/VBoxContainer/Missiles/Control.show()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Bombs/Control.hide()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Guns/Control.hide()
    elif select == 3:
        current_weapon = "bomb"
        $CanvasLayer/HUD/Weapons/VBoxContainer/Missiles/Control.hide()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Bombs/Control.show()
        $CanvasLayer/HUD/Weapons/VBoxContainer/Guns/Control.hide()


func _on_CannonCoolDown_timeout() -> void:
    $CannonCoolDown.stop()
    cannon_ready = true
