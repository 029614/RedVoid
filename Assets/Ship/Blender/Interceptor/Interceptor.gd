extends KinematicBody2D

#References
var scene = Global.world
var pilot
onready var faction = get_parent().get_parent()

#Preloads
var missile = preload("res://Assets/Ship/Weapons/Missile.tscn")
var shot = preload("res://Assets/Ship/Weapons/Shot.tscn")
var explosion = preload("res://Assets/Particles/Explosion.tscn")

#States
var location_states = ["in_orbit", "on_planet", "landing", "in_formation", "free"]
var location_state = "free"

var cannon_states = ["fire", "cooldown"]
var cannon_state = "fire"

#Animation Switches
var animate_engines = false
var animate_cannons = false
var animate_203 = false
var animate_408 = false
var animate_after_burner = false

#Action Switches
var fire_rotary = false
var fire_missile = false
var fire_bomb = false
var fire_203 = false
var fire_408 = false
var fire_after_burner = false
var fire_engines = false

#Ship Performance
var thrust = 5000
var mass = 10
var max_speed = 2000
export (float) var rotation_speed = 2
onready var acceleration = thrust/mass
onready var rps = 1.0/rotation_speed
onready var rads_per_sec = 6.283185*rps

#Ship Specifics
onready var gun_coords = $GunCoords
export var fuel = 5000
var fuel_cap = 5000
var shields = 100
var ship_size = 1
var detection_radius = 5000 #how far this ship can detect enemies

#Weapons
var weapons = ["cannon", "rocket", "laser", "turrets"]

#Ship active physics
var thrust_modifier = 1
var velocity = Vector2()
var current_speed = 0

var gravity_interval = 0.1
onready var gravity_timer = Timer.new()
var do_gravity = 1



func _ready() -> void:
    #$Accent.modulate = faction.faction_color
    pass
    
    connect("base_destroyed", self, "_baseDestroyed")
    
    add_child(gravity_timer)
    gravity_timer.connect("timeout",self,"_gravity_timer_timeout")
    gravity_timer.set_timer_process_mode(0)
    gravity_timer.set_one_shot(false)
    gravity_timer.start(gravity_interval)

func _gravity_timer_timeout():
    do_gravity=1         
        
func getGravity():
    var g = Vector2(0,0)
    for body in get_node("/root/NewMain/Navigation2D/Bodies").get_children():
        #print("body: ",body)
        g += ( body.mass / (body.global_position.distance_to(self.global_position)) * self.global_position.direction_to(body.global_position) )
    return g

func glide():
    animate_engines = false
    
func rotateShip(delta, direction, max_rot):
    rotation += clamp(direction * rotation_speed * delta, -max_rot, max_rot)

func accelerate(delta):
    if fuel >= 0:
        current_speed = velocity.length()
        velocity += Vector2(1, 0).rotated(rotation).normalized() * acceleration * delta * thrust_modifier
        velocity = velocity.clamped(max_speed)
        #fuel -= 1 * (thrust_modifier * 2)
        animate_engines = true
    else:
        animate_engines = false

func _physics_process(delta: float) -> void:
    #rotation = pilot.rotation
    if location_state == "free":
        if do_gravity:
            do_gravity = 0
            velocity += getGravity() * gravity_interval
            velocity = velocity.clamped(max_speed)
            
        velocity = move_and_slide(velocity)
        

func fireControl(weapon):
    if weapon == "missile":
        var m = missile.instance()
        m.velocity = velocity
        m.rotation = rotation
        Global.world.add_child(m)
        m.global_position = gun_coords.get_global_position()
    elif weapon == "cannon" and cannon_state == "fire":
        var m = shot.instance()
        m.gun_speed = current_speed
        m.rotation = global_rotation
        m.shooter = self
        m.ship_velocity = pilot.velocity
        Global.world.add_child(m)
        m.global_position = gun_coords.get_global_position()
        cannon_state = "cooldown"
        $CannonCoolDown.start()


func destruct():
    $Sprite.hide()
    var e = explosion.instance()
    add_child(e)
    e.get_node("Particles2D").set_emitting(true)


func _on_CannonCoolDown_timeout() -> void:
    cannon_state = "fire"
    

func proximityScan(sector):
    var nearby_enemies = []
    var nearby_bodies = []
    var nearby_allies = []
    for other_ship in sector.ships():
        if global_position.distance_to(other_ship.global_position) <= detection_radius:
            if other_ship.pilot.faction != pilot.faction:
                nearby_enemies.append(other_ship)
            elif other_ship.pilot.faction == pilot.faction:
                nearby_allies.append(other_ship)
    for body in sector.bodies:
        if global_position.distance_to(body.global_position) <= detection_radius:
            nearby_bodies.append(body)
    return [nearby_enemies, nearby_bodies]
    
func estimateStrength():
    var weapon_strength = 1
    var shield_strength = 1
    return weapon_strength + shield_strength
