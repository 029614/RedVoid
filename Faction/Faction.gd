extends Node


onready var faction_color = Color8(1,1,1,1)
var possible_colors = [Color8(28,99,255,255),Color8(255,216,0,255),Color8(255,14,0,255),Color8(0,255,171,255),Color8(185,0,255,255),Color8(92,255,0,255)]
onready var faction_color_alpha = Color8(faction_color.r8,faction_color.g8,faction_color.b8,100)
export var faction_name = "No Name"
var planets = []
var home_planet = null
var player = false
var instance = false

var scoutship = preload("res://Assets/Ship/Blender/ScoutShip/ScoutShip.tscn")
var interceptor = preload("res://Assets/Ship/Blender/Interceptor/Interceptor.tscn")
var destroyer = preload("res://Assets/Ship/Blender/Destroyer/Destroyer.tscn")
var battleship = preload("res://Assets/Ship/Blender/Battleship/Battleship.tscn")
var ai = preload("res://AI/AIPilot.tscn")
var player_script = preload("res://Player/Player.tscn")


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
    

func createScoutShip(pilot_type):
    var new_pilot
    if pilot_type == "player":
        new_pilot = player_script.instance()
    elif pilot_type == "ai":
        new_pilot = ai.instance()
    var new_scout = scoutship.instance()
    new_scout.get_node("Pilot").add_child(new_pilot)
    $Scouts.add_child(new_scout)
    print(self, " ship list: ", get_faction_ships())
    
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





