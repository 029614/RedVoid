extends Node


export (Color) var faction_color = Color8(1,1,1,1)
var possible_colors = [Color8(28,99,255,255),Color8(255,216,0,255),Color8(255,14,0,255),Color8(0,255,171,255),Color8(185,0,255,255),Color8(92,255,0,255)]
var faction_color_alpha
export var faction_name = "No Name"
var planets = []

var scoutship = preload("res://Assets/Ship/Blender/ScoutShip/ScoutShip.tscn")
var interceptor = preload("res://Assets/Ship/Blender/Interceptor/Interceptor.tscn")
var destroyer = preload("res://Assets/Ship/Blender/Destroyer/Destroyer.tscn")
var battleship = preload("res://Assets/Ship/Blender/Battleship/Battleship.tscn")


#Resources

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    faction_color_alpha = Color8(faction_color.r8, faction_color.g8, faction_color.b8, 100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func get_faction_ships():
    var ships = {}
    for section in self.get_children():
        ships[section] = section.get_children()
    return ships

func get_faction_interceptors():
    return $Interceptors.get_children()
    
func get_faction_freighters():
    return $Freighters.get_children()

func get_faction_Scouts():
    return $Scouts.get_children()

func get_faction_Bombers():
    return $Bombers.get_children()

func get_faction_Destroyers():
    return $Destroyers.get_children()

func get_faction_Battleships():
    return $Battleships.get_children()
    
func get_faction_planets():
    pass



func set_faction_color(color):
    pass
    
func get_faction_color():
    pass



func set_faction_name(new_name):
    pass

func get_faction_name():
    pass





