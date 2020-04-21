extends KinematicBody2D

#References
var scene = Global.world
var pilot


#Preloads
var missile = preload("res://Assets/Ship/Weapons/Missile.tscn")
var shot = preload("res://Assets/Ship/Weapons/Shot.tscn")
var explosion = preload("res://Assets/Particles/Explosion.tscn")

#States
var location_states = ["in_orbit", "on_planet", "in_formation", "free"]
var location_state = "free"

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
onready var acceleration = thrust/mass
var current_speed
var max_speed = 1500
export (float) var rotation_speed = 2

var thrust_modifier = 1
var velocity = Vector2()

#Ship Specifics
onready var gun_coords = $GunCoords
export var fuel = 5000
var fuel_cap = 5000
var shields = 100
var ship_size = 1

#Controls
var rotation_dir






func _ready() -> void:
    pass


func _physics_process(delta: float) -> void:
    if pilot:
        rotation = pilot.rotation
    #After Burner
    if animate_after_burner == true:
        thrust_modifier = 10
        $Sprite/AB1.set_emitting(true)
        $Sprite/AB2.set_emitting(true)
        $EngineSound.set_volume_db(6)
    elif animate_after_burner == false:
        thrust_modifier = 1
        $Sprite/AB1.set_emitting(false)
        $Sprite/AB2.set_emitting(false)
        $EngineSound.set_volume_db(1)

    #Changing the sprite to the one with engine plumes
    if animate_engines == true:
        if $Sprite/Particles2D.is_emitting() == false:
            $Sprite/Particles2D.restart()
            #$Sprite/Particles2D.set_emitting(true)
            $EngineSound.play()
    else:
        $Sprite/Particles2D.set_emitting(false)
        #$Sprite/Particles2D.set_emitting(true)
        $EngineSound.stop()


func someFunc():
    #After Burner
    if animate_after_burner == true:
        thrust_modifier = 10
        $Sprite/AB1.set_emitting(true)
        $Sprite/AB2.set_emitting(true)
        $EngineSound.set_volume_db(6)
    elif animate_after_burner == false:
        thrust_modifier = 1
        $Sprite/AB1.set_emitting(false)
        $Sprite/AB2.set_emitting(false)
        $EngineSound.set_volume_db(1)

    #Changing the sprite to the one with engine plumes
    if $Sprite/Particles2D.is_emitting() == false:
        $Sprite/Particles2D.restart()
        #$Sprite/Particles2D.set_emitting(true)
        $EngineSound.play()

func fireControl(weapon):
    if weapon == "missile":
        var m = missile.instance()
        m.velocity = velocity
        m.rotation = rotation
        Global.world.add_child(m)
        m.global_position = gun_coords.get_global_position()
    elif weapon == "cannon":
        var m = shot.instance()
        m.gun_speed = current_speed
        m.rotation = global_rotation
        m.shooter = self
        Global.world.add_child(m)
        m.global_position = gun_coords.get_global_position()
        $CannonCoolDown.start()


func destruct():
    $Sprite.hide()
    var e = explosion.instance()
    add_child(e)
    e.get_node("Particles2D").set_emitting(true)
