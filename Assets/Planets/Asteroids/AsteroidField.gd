extends Node2D


var asteroid1 = preload("res://Assets/Planets/Asteroids/Asteroid1.tscn")
var asteroid2 = preload("res://Assets/Planets/Asteroids/Asteroid2.tscn")
var asteroid3 = preload("res://Assets/Planets/Asteroids/Asteroid3.tscn")
var asteroid4 = preload("res://Assets/Planets/Asteroids/Asteroid4.tscn")
var asteroid5 = preload("res://Assets/Planets/Asteroids/Asteroid5.tscn")
var asteroids = []
var size = 0
var asteroid_field = []
var family


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    asteroids = [asteroid1, asteroid2, asteroid3, asteroid4, asteroid5]
    size = randi()%75+10
    generate()
    self.rotation = rand_range(0,360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass


func generate():
    var x = 0
    while x < size:
        randomize()
        var new_asteroid = asteroids[rand_range(0,4)].instance()
        var rscale = rand_range(.1,.8)
        new_asteroid.global_scale = Vector2(rscale, rscale)
        #new_asteroid.sprite.set_flip_h(randBool())
        #new_asteroid.sprite.set_flip_v(randBool())
        add_child(new_asteroid)
        new_asteroid.position = Vector2((new_asteroid.position.x - 2000) + randi()%4000,(new_asteroid.position.y - 4000) + randi()%8000)
        x += 1

func randBool():
    if randi()%2 == 1:
        return true
    else:
        return false
