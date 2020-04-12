extends Node2D


var planet = preload("res://UI/Map/Planet.tscn")
var ship = preload("res://UI/Map/Ship.tscn")
onready var HUD = get_parent().get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Global.connect("send_planets", self, "placePlanets")
    Global.connect("main_ready", self, "begin")
    print("requesting planets")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    placeShips()


func begin():
    Global.emit_signal("request_planets")


func placeShips():
    pass

func placePlanets(positions):
    print("placing planets")
    for pos in positions:
        var p = planet.instance()
        $Planets.add_child(p)
        p.set_position(pos)
        print("added planet")
