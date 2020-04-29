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
signal map_ready


#Player Event Flags !!!!MOVE TO ACTOR SCRIPT!!!!
var _process_player_movement = false
var _player_is_launched = true
var _player_in_orbit = false

#Global Conditions
var _play = false

#Player info
var player_faction = "69 69 Fuck yeah Awesome"
var player_color = Color8(59,183,45,125)

var colors = [Color8(28,99,255,255), Color8(255,216,0,255), Color8(255,14,0,255), Color8(0,255,171,255), Color8(185,0,255,255), Color8(93,255,0,255)]

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


#Global References
var HUD = null
var world = null
var player_registry = []
var bodies
var astNames = []
var asteroidFamilies = []

#Other stuff I think I need
var pi = 3.141

#Import addresses
var import_asteroid_names = "res://Assets/Planets/Asteroids/names.cfg"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
func messageAll(message):
    for player in player_registry:
        player.hud.set_message(str(message))
        player.hud.beep()

func asteroidNames():
    var configFile = ConfigFile.new()
    var err = configFile.load(import_asteroid_names)
    if err == OK:
        print("INI accessed successfully")
        var sKeys = configFile.get_section_keys("names")
        for key in sKeys:
            astNames.append(configFile.get_value("names", key))
    else:
        print("INI failed to load: ", err)

func getClosest(array:Array,pos:Vector2):
    var closest = null
    for obj in array:
        if closest == null or obj.get_global_position().distance_to(pos) <= closest.get_global_position().distance_to(pos):
            closest = obj
    return closest.global_position

        

func time_of_flight(velocity,distance,acceleration): #all values are floats
    var total = (sqrt(velocity*velocity+2*acceleration*distance) - velocity) / acceleration
    #print("time of flight, v, d, a, total: ",velocity,", ",distance,", ",acceleration,", ",total)
    return total

func time_to_decelerate(velocity,acceleration): #all values are floats
    return velocity/float(acceleration)
    
func time_to_match_velocity(velocity,acceleration,other_vel): #all values are floats
    print("time to match vel: ",velocity," , ",acceleration," , ",other_vel," , ",(velocity-other_vel).length())
    return (velocity-other_vel).length()/float(acceleration)
    
func time_to_rotate(rps, current_rotation, desired_rotation):
    print("current_rotation: ", current_rotation, " desired_rotation: ", desired_rotation, 
        " time_to_rotate: ", abs(desired_rotation - current_rotation) / rps)
    return abs((desired_rotation - current_rotation) / rps)


func average(a):
    var s = 0.0
    for i in a:
        s+=i
    s=s/a.size()
    return s
