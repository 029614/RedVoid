extends Node


export (Color) var faction_color = Color(1,1,1,1)
export var faction_name = "No Name"
var planets = []

var state_dictionary = {
    "faction": {
        "has_planet":false, # if the faction has at least 1 planet
        "is_losing_planet":false, # if the faction has a planet under attack
        "is_losing_only_planet":false, # if the faction is losing their ONLY planet
        "is_losing_freighter":false, # if freighter of the faction is being attacked
        "is_invaded":false, # if enemy fighters have been detected within the terratory of the faction
       }
    }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
