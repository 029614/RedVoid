extends Node2D


""" -------- DECLARATION -------- """
onready var bodies = Global.bodies
onready var engine = Global.world
onready var last_position = get_position()
var ship
var faction
var hud
var fuel_gauge

#input and direction
var velocity = Vector2()
var rotation_dir = 0
var orbital_pos
var orbit = {}
var planet
var zoom = Vector2()
var zoom_interval = Vector2(1,1)
var zoom_min = Vector2(5,5)
var zoom_max = Vector2(250,250)
var zoom_normal = Vector2(3,3)
var map_center_relative

#Ship
var ship_size
var target = null

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

var camera_states = ["zoomed_in", "zoomed_out", "zooming_in", "zooming_out", "tile", "map", "normal"]
var camera_state = "normal"
var camera_positions = ["on_player", "on_center"]
var camera_position = "on_player"



""" -------- FUNCTIONS -------- """
#initialize variables
func _ready():
    
    #Connecting signals and presetting flags
    Global.connect("player_arrival", self, "setupOrbit")
    Global.connect("player_died", self, "destruct")
    Global._process_player_movement = true
    Global.player_registry.append(self)
    $CanvasLayer/HUD.player = self
    $ChaseCamera.zoom = zoom_normal
    map_center_relative = global_position + Global.world.map_center
    print("ec return all: ", Global.ec_get_ship_list())
    print("ec return faction 1: ", Global.ec_get_ship_list("faction1"))


func startUp():
    ship = get_parent().get_parent()
    faction = ship.get_parent().get_parent()
    hud = $CanvasLayer/HUD
    fuel_gauge = $CanvasLayer/HUD/ConsoleFuel/FuelGauge
    ship.pilot_ref = self
    ship.faction = faction
    map_center_relative = global_position + Global.world.map_center
    hud.startUp()
    $ChaseCamera.make_current()
    ship_size = ship.ship_size

func get_input(delta):
    
    rotation_dir = 0
    #Directional Inputs
    if ship.location_state == "free":
        if Input.is_action_pressed('ui_right'):
            ship.rotateShip(delta, 1, ship.rads_per_sec*delta)
        if Input.is_action_pressed('ui_left'):
            ship.rotateShip(delta, -1, ship.rads_per_sec*delta)
        if Input.is_action_pressed('ui_down'):
            if ship.rotation < ship.velocity.normalized().rotated(deg2rad(180)).angle():
                ship.rotateShip(delta, 1, ship.rads_per_sec*delta)
            elif ship.rotation > ship.velocity.normalized().rotated(deg2rad(180)).angle():
                ship.rotateShip(delta, -1, ship.rads_per_sec*delta)
        if Input.is_action_pressed('ui_up') and ship.fuel >= 0:
            ship.accelerate(delta)
        else:
            ship.glide()
                

func _physics_process(delta):
    if Global._play == true:
        get_input(delta)
        
        if ship.location_state == "in_orbit":
            ship.global_position = orbital_pos.get_global_position()
            ship.look_at(planet.get_global_position())
            ship.rotation += deg2rad(-90)
            
        elif ship.location_state == "landing":
            #print("player has now landed")
            ship.location_state = "on_planet"
        
        #Map
        if camera_state == "zooming_out" and $ChaseCamera.zoom < zoom_max:
            $ChaseCamera.zoom += zoom_interval
            for label in hud.field_labels:
                label.scale += zoom_interval
        elif camera_state == "zooming_out" and $ChaseCamera.zoom > zoom_max:
            $ChaseCamera.zoom = zoom_max
            for label in hud.field_labels:
                label.scale = zoom_max
        elif camera_state == "zooming_out" and $ChaseCamera.zoom == zoom_max:
            camera_state = "zoomed_out"
        
        if camera_state == "map":
            $ChaseCamera.set_global_position(map_center_relative)
            
        if camera_state == "zooming_in" and $ChaseCamera.zoom > Vector2(3*ship_size,3*ship_size):
            $ChaseCamera.zoom -= zoom_interval
            for label in hud.field_labels:
                label.scale -= zoom_interval
        elif camera_state == "zooming_in" and $ChaseCamera.zoom < Vector2(3*ship_size,3*ship_size):
            $ChaseCamera.zoom = Vector2(3*ship_size,3*ship_size)
            for label in hud.field_labels:
                label.scale = Vector2(3*ship_size,3*ship_size)
        elif camera_state == "zooming_in" and $ChaseCamera.zoom == Vector2(3*ship_size,3*ship_size):
            camera_state = "zoomed_in"
        
        if $ChaseCamera.zoom < Vector2(10,10):
            hud.player_ind.hide()
        elif $ChaseCamera.zoom >= Vector2(10,10):
            hud.player_ind.show()
            hud.player_ind.set_scale($ChaseCamera.zoom/2)
        hud.player_ind.set_global_rotation(ship.get_global_rotation() + deg2rad(90))
        hud.player_ind.set_global_position(global_position)
        
        
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
        if ship.location_state == "free" and current_weapon == "cannon" and ship.firing_cannon == false and Input.is_action_pressed("weapons"):
            ship.firing_cannon = true
            hud.cannon(true)
        elif ship.location_state == "free" and current_weapon == "cannon" and ship.firing_cannon == true and Input.is_action_just_released("weapons"):
            ship.firing_cannon = false
            #print("Trigger Released")
            hud.cannon(false)
        
        #Targeting
        if Input.is_action_pressed("toggle_target"):
            var targets = get_tree().get_nodes_in_group("ship")
            var closest_target = Global.getClosest(ship, targets, ship.global_position)
            print("closest target: ", closest_target, " Name: ", closest_target.name)
            target = closest_target
            hud.target(closest_target)
        
        #Camera Zoom
        if Input.is_action_pressed("zoom_in") and camera_state == "normal":
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x - .1, $ChaseCamera.get_zoom().y - .1))
            for label in hud.field_labels:
                label.scale -= Vector2(.1,.1)
        if Input.is_action_pressed("zoom_out") and camera_state == "normal":
            $ChaseCamera.set_zoom(Vector2($ChaseCamera.get_zoom().x + .1, $ChaseCamera.get_zoom().y + .1))
            for label in hud.field_labels:
                label.scale += Vector2(.1,.1)
        
        #Map
        if Input.is_action_just_pressed("map") and camera_state != "map":
            camera_state = "map"
            if $ChaseCamera.zoom < zoom_max:
                $ChaseCamera.zoom = zoom_max
            for label in hud.field_labels:
                label.scale = zoom_max
        elif Input.is_action_just_pressed("map") and camera_state == "map":
            camera_state = "normal"
            $ChaseCamera.global_position = global_position
            if $ChaseCamera.zoom > zoom_normal:
                $ChaseCamera.zoom = zoom_normal
            for label in hud.field_labels:
                label.scale = zoom_normal*2
        
        if Input.is_action_just_pressed("tile") and camera_state != "tile":
            camera_state = "tile"
            $ChaseCamera.global_position = global_position
            if $ChaseCamera.zoom != zoom_max/4:
                $ChaseCamera.zoom = zoom_max/4
            for label in hud.field_labels:
                label.scale = zoom_max/4
        elif Input.is_action_just_pressed("tile") and camera_state == "tile":
            camera_state = "normal"
            $ChaseCamera.global_position = global_position
            if $ChaseCamera.zoom > zoom_normal:
                $ChaseCamera.zoom = zoom_normal
            for label in hud.field_labels:
                label.scale = zoom_normal*2
        
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

func setupOrbit(orbit_data, target):
    planet = target
    orbit = orbit_data
    #print("Orbital Coordinates Received")
    
func orbit(orbit, planet):
    var o = Navigation2D.new()
    orbit.add_child(o)
    o.global_position = global_position
    orbital_pos = o
    ship.location_state = "in_orbit"
#    var p_pos = ship.get_global_position()
#    var obd = {} # Orbit By Distance. Contains a list of orbits. orbit reference:distance from ship
#    for pos in orbit:
#        if orbit.get(pos) == false:
#            obd[pos] = pos.get_global_position().distance_to(p_pos)
#    var s = obd.values()
#    s.sort()
#    for key in obd:
#        if obd[key] == s[0]:
#            orbital_pos = key
#    ship.location_state = "in_orbit"
#    print("all code has run")

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
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Missiles/Control.hide()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Bombs/Control.hide()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Guns/Control.show()
    elif select == 2:
        current_weapon = "missile"
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Missiles/Control.show()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Bombs/Control.hide()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Guns/Control.hide()
    elif select == 3:
        current_weapon = "bomb"
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Missiles/Control.hide()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Bombs/Control.show()
        $CanvasLayer/HUD/ConsoleRight/Weapons/VBoxContainer/Guns/Control.hide()


func _on_CannonCoolDown_timeout() -> void:
    $CannonCoolDown.stop()
    cannon_ready = true
