extends KinematicBody2D


var explosion = preload("res://Assets/explosions/explosion1/Explosion1.tscn")

export var speed = 800
export var rotation_speed = 10
export var cargo_capacity = 125
var cargo = 0
var explode_time = 100
var destructing = false


var target
var base_pos
var base
var start_pos
var base_distance
var target_distance
var resource
var velocity

var cannon_strikes = false

var health = 100

var move_status = "idle" #idle, going_to_target, going_to_base, loading, unloading, landing


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    if move_status == "going_to_target" and self.global_position.distance_to(target) > 50:
        look_at(target)
        velocity = Vector2(1, 0).rotated(rotation).normalized() * speed
        velocity = move_and_slide(velocity)
    
    elif move_status == "going_to_target" and self.global_position.distance_to(target) <= 50:
        look_at(target)
        rotation += deg2rad(90)
        move_status = "loading"
    
    elif move_status == "loading" and cargo < cargo_capacity:
        cargo += 0.2
    
    elif move_status == "loading" and cargo >= cargo_capacity:
        move_status = "going_to_base"
    
    elif move_status == "going_to_base" and self.global_position.distance_to(base_pos) > 50:
        look_at(base_pos)
        velocity = Vector2(1, 0).rotated(rotation).normalized() * speed
        velocity = move_and_slide(velocity)
    
    elif move_status == "going_to_base" and self.global_position.distance_to(base_pos) <= 50:
        look_at(base_pos)
        rotation += deg2rad(90)
        #move_status = "unloading"
        move_status = "landing"
    
    elif move_status == "unloading" and cargo > 0:
        cargo -= 0.2
        base.materials += 0.2
    
    elif move_status == "unloading" and cargo <= 0:
        self.queue_free()
    
    elif move_status == "landing" and scale > Vector2(0.1,0.1):
        scale -= Vector2(.1,.1)
        look_at(base_pos)
        velocity = Vector2(1, 0).rotated(rotation).normalized() * speed
        velocity = move_and_slide(velocity)
    
    elif move_status == "landing" and scale <= Vector2(0.1,0.1):
        base.materials += cargo
        self.queue_free()
    
    if health <= 0:
        destructing = true
    
    if cannon_strikes == true:
        cannonStrike()
    
    if destructing == true:
        explode()
        explode_time -= 1

func job(destination):
    target = destination
    move_status = "going_to_target"
    target_distance = self.global_position.distance_to(destination)
    base_distance = destination.distance_to(base_pos)

func loadResource():
    pass

func unloadResource():
    pass

func cannonStrike():
    var new_exp = explosion.instance()
    add_child(new_exp)
    new_exp.scaler(8)
    new_exp.global_position = Vector2(rand_range($ExplosionContainer/Start.global_position.x, $ExplosionContainer/End.global_position.x), rand_range($ExplosionContainer/Start.global_position.y, $ExplosionContainer/End.global_position.y))
    new_exp.play()
    health -= 1

func explode():
    if explode_time > 0:
        var new_exp = explosion.instance()
        add_child(new_exp)
        new_exp.scaler(5)
        new_exp.global_position = Vector2(rand_range($ExplosionContainer/Start.global_position.x, $ExplosionContainer/End.global_position.x), rand_range($ExplosionContainer/Start.global_position.y, $ExplosionContainer/End.global_position.y))
        new_exp.begin()
    else:
        finalExplosion()

func finalExplosion():
    var new_exp = explosion.instance()
    add_child(new_exp)
    new_exp.scaler(.5)
    new_exp.final_explosion = true
    new_exp.global_position = Vector2(rand_range($ExplosionContainer/Start.global_position.x, $ExplosionContainer/End.global_position.x), rand_range($ExplosionContainer/Start.global_position.y, $ExplosionContainer/End.global_position.y))
    new_exp.begin()
    
    
