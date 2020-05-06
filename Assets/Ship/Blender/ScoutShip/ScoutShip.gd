extends KinematicBody2D

#References
var scene = Global.world
onready var pilot = $Pilot.get_children()[0]
var pilot_ref
onready var faction = get_parent().get_parent()

#Preloads
var missile = preload("res://Assets/Ship/Weapons/Missile.tscn")
var shot = preload("res://Assets/Ship/Weapons/Shot.tscn")
var explosion = preload("res://Assets/explosions/explosion1/Explosion1.tscn")

#States
var location_states = ["in_orbit", "on_planet", "landing", "in_formation", "free"]
var location_state = "free"

var cannon_states = ["fire", "cooldown"]
var cannon_state = "idle"

#Animation Switches
var animate_engines = false
var animate_cannons = false
var animate_203 = false
var animate_408 = false
var animate_after_burner = false

#Animation States
var engine_state = "off"

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
var cannon_strikes = false
var firing_cannon = false

#Ship active physics
var thrust_modifier = 1
var velocity = Vector2()
var current_speed = 0

var gravity_interval = 0.1
onready var gravity_timer = Timer.new()
var do_gravity = 1



func _ready() -> void:
    #$Accent.modulate = faction.faction_color
    
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
    
    if animate_engines and engine_state == "off":
        $Engine1.show()
        $JetSound.play(0.0)
        engine_state = "on"
    elif animate_engines == false and engine_state == "on":
        $Engine1.hide()
        $JetSound.stop()
        engine_state = "off"
    
    if cannon_strikes == true:
        cannonStrike()
    
    if firing_cannon == true and cannon_state == "idle":
        fireCannon()
    elif firing_cannon == false and cannon_state == "firing":
        stopFire()
        

func fireCannon():
    $GunCoords/ParticleBullets.fire(true)
    cannon_state = "firing"
    print("FIRE!")
    $Bullets.set_monitoring(true)


func fireControl(weapon):
    if weapon == "cannon" and firing_cannon == true and cannon_state == "idle":
        $GunCoords/ParticleBullets.fire(true)
        cannon_state = "firing"
        #var m = shot.instance()
        #m.gun_speed = current_speed
        #m.rotation = global_rotation
        #m.shooter = self
        #m.ship_velocity = pilot.velocity
        #Global.world.add_child(m)
        #m.global_position = gun_coords.get_global_position()
        #cannon_state = "cooldown"
        #$CannonCoolDown.start()

func stopFire():
    $GunCoords/ParticleBullets.fire(false)
    cannon_state = "idle"
    print("CEASE FIRE! CEASE FIRE!!!!")
    $Bullets.set_monitoring(false)


func destruct():
    $Sprite.hide()
    var e = explosion.instance()
    add_child(e)
    e.get_node("Particles2D").set_emitting(true)


func _on_CannonCoolDown_timeout() -> void:
    #cannon_state = "fire"
    pass
    

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


func _on_Bullets_area_entered(area: Area2D) -> void:
    if area.name == "HitBoxT" and area.get_parent() != self and firing_cannon == true:
        area.get_parent().cannon_strikes = true
    elif area.name == "HitBoxT" and firing_cannon == false:
        area.get_parent().cannon_strikes = false

func cannonStrike():
    var new_exp = explosion.instance()
    add_child(new_exp)
    new_exp.scaler = 5
    new_exp.global_position = Vector2(rand_range($ExplosionContainer/Start.global_position.x, $ExplosionContainer/End.global_position.x), rand_range($ExplosionContainer/Start.global_position.y, $ExplosionContainer/End.global_position.y))
    new_exp.begin()


func _on_Bullets_area_exited(area: Area2D) -> void:
    if area.name == "HitBoxT":
        area.get_parent().cannon_strikes = false
