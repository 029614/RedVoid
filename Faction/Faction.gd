extends Node


export (Color) var faction_color = Color8(1,1,1,1)
var faction_color_alpha
export var faction_name = "No Name"
var planets = []


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





