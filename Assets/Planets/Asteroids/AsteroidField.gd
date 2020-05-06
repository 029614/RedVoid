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
var mass = 0
var ownership = null
var tile

var planet_state = "empty"
var capture_perc = 0
var capturing_fac = null
var capturing_ship = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    asteroids = [asteroid1, asteroid2, asteroid3, asteroid4, asteroid5]
    size = randi()%70+10
    generate()
    self.rotation = rand_range(0,360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    
    #Capturing
    if planet_state == "being_captured" :
        if capture_perc < 100.0:
            capture_perc += .1
        elif capture_perc >= 100:
            capture_perc = 100
            capture(capturing_fac, self)
            capturing_fac = null
    
    if planet_state == "empty" and capture_perc > 0:
        capture_perc -= .1


func generate():
    var x = 0
    var first_asteroid = asteroids[rand_range(0,4)].instance()
    first_asteroid.global_scale = Vector2(2,2)
    first_asteroid.get_node("Sprite").set_flip_h(randBool())
    first_asteroid.get_node("Sprite").set_flip_v(randBool())
    first_asteroid.rotation = deg2rad(rand_range(1,360))
    add_child(first_asteroid)
    first_asteroid.position = Vector2(0,0)
    while x < size:
        randomize()
        var new_asteroid = asteroids[rand_range(0,4)].instance()
        var rscale = rand_range(.05,1)
        new_asteroid.global_scale = Vector2(rscale, rscale)
        new_asteroid.get_node("Sprite").set_flip_h(randBool())
        new_asteroid.get_node("Sprite").set_flip_v(randBool())
        new_asteroid.rotation = deg2rad(rand_range(1,360))
        add_child(new_asteroid)
        new_asteroid.position = Vector2((new_asteroid.position.x - 4000) + randi()%8000,(new_asteroid.position.y - 4000) + randi()%8000)
        x += 1

func randBool():
    if randi()%2 == 1:
        return true
    else:
        return false


func capture(faction, planet):
    if ownership != faction and planet == self:
        ownership = faction
        faction.planets.append(self)
        var message = str(name) + " has been captured by " + str(faction.name) + "."
        Global.messageAll(message)
        $Sprite.self_modulate = ownership.faction_color
        planet_state = "occupied"
        Global.emit_signal("capture", faction)


func _on_Area2D_body_entered(body: Node) -> void:
    if body.name == "ScoutShip" and body.faction != ownership:
        planet_state = "being_captured"
        capturing_fac = body.faction
        capturing_ship = body


func _on_Area2D_body_exited(body: Node) -> void:
    if body == capturing_ship and planet_state == "being captured":
        planet_state = "empty"
        capturing_fac = null
        capturing_ship = null
