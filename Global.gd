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


#Player Event Flags
var _process_player_movement = false
var _player_is_launched = true
var _player_in_orbit = false

#Player info
var player_faction = "69 69 Fuck yeah Awesome"
var player_color = Color8(59,183,45,255)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
