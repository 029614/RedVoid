extends Node


#Signals
signal player_died
signal player_landed
signal player_arrival
signal freighter_arrival
signal request_planets
signal send_planets
signal main_ready


#Player Event Flags
var _is_player_picked = false
var _process_player_movement = false
var _player_is_launched = true
var _player_is_landed = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
