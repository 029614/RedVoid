extends Node


onready var faction_color = Color8(1,1,1,1)
var possible_colors = [Color8(28,99,255,255),Color8(255,216,0,255),Color8(255,14,0,255),Color8(0,255,171,255),Color8(185,0,255,255),Color8(92,255,0,255)]
onready var faction_color_alpha = Color8(faction_color.r8,faction_color.g8,faction_color.b8,100)
export var faction_name = "No Name"
var planets = []
var home_planet = null
var player = false
var instance = false


onready var shuttles = $Shuttles
onready var freighters = $Freighters
onready var scoutships = $Scouts
onready var interceptors = $Interceptors
onready var bombers = $Bombers
onready var destroyers = $Destroyers
onready var battleships = $Battleships


#Resources

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    faction_color = Global.player_color
    faction_color_alpha = Color8(faction_color.r8, faction_color.g8, faction_color.b8, 100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func changeColor(color, color_a):
    faction_color = color
    faction_color_alpha = color_a
    
func shipsToHome():
    var ships = get_faction_ships()
    for ship in ships:
        ship.global_position = Vector2(home_planet.global_position.x + 1000, home_planet.global_position.y + 1000)
        
func findScoutTarget():
    var p = get_tree().get_nodes_in_group("planets")
    var closest = null
    for planet in p:
        if planet.ownership == null:
            if closest == null:
                closest = planet
            elif home_planet.global_position.distance_to(planet.global_position) < home_planet.global_position.distance_to(closest.global_position):
                closest = planet
    return closest

func dispatcher(ship):
    if findScoutTarget():
        ship.pilot.goTo(findScoutTarget())
            
func get_faction_ships():
    var ships = []
    for section in self.get_children():
        for ship in section.get_children():
            ships.append(ship)
    return ships

func createPath():
    pass

func nextPOI(ship):
    pass




