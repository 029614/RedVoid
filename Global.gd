extends Node


#Signals
signal player_died
signal player_landed
signal player_arrival
signal freighter_arrival
signal request_planets
signal send_planets
signal main_ready
signal capture_planet
signal torpedo_request


#Player Event Flags !!!!MOVE TO ACTOR SCRIPT!!!!
var _process_player_movement = false
var _player_is_launched = true
var _player_in_orbit = false

#Global Conditions
var _play = false

#Player info
var player_faction = "69 69 Fuck yeah Awesome"
var player_color = Color8(59,183,45,255)

#Faction info
#Faction dictionary. Faction id:{Color:Faction Color, Name: Faction Name, _is_npc: Bool}
var faction_list = {
    "Template":{
        "Color":Color8(0,0,0,0),
        "Name":"Faction Name",
        "_is_npc": true
       }
   }

#Map Info
var map_origin = Vector2(0,0)
var map_limit = Vector2(20000,12000)
var number_of_planets = 0
var number_of_factions = 0



func time_of_flight(velocity,distance,acceleration): #all values are floats
    var total = (sqrt(velocity*velocity+2*acceleration*distance) - velocity) / acceleration
    print("time of flight, v, d, a, total: ",velocity,", ",distance,", ",acceleration,", ",total)
    return total

func time_to_decelerate(velocity,acceleration): #all values are floats
    return velocity/float(acceleration)


func average(a):
    var s = 0.0
    for i in a:
        s+=i
    s=s/a.size()
    return s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
