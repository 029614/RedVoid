extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func get_factions():
    var list = {}
    for faction in $Navigation2D/Factions.get_children():
        list[faction.name] = {"ID":faction, "faction_name":faction.faction_name}
    return list

func new_faction(faction_name, faction_color):
    pass

func delete_faction():
    pass



func get_bodies():
    return $Navigation2D/Bodies.get_children()
