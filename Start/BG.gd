extends Node2D


var relative_x
var relative_y
var mouse_x = 0
var mouse_y = 0
var mod = 10
var wait = true
onready var viewport_size = get_viewport().size


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    wait = false

func _input(event):
    if event is InputEventMouseMotion:
        mouse_x = event.position.x
        mouse_y = event.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if wait == false:
        relative_x = -(mouse_x - (viewport_size.x/2)) / (viewport_size.x/2)
        relative_y = -(mouse_y - (viewport_size.y/2)) / (viewport_size.y/2)
        $Canvas/ParallaxLayer.motion_offset.x = .5 * mod * relative_x
        $Canvas/ParallaxLayer.motion_offset.y = .5 * mod * relative_y
        
        $Nebula/ParallaxLayer.motion_offset.x = 1 * mod * relative_x
        $Nebula/ParallaxLayer.motion_offset.y = 1 * mod * relative_y
        
        $Layer1/ParallaxLayer.motion_offset.x = 2 * mod * relative_x
        $Layer1/ParallaxLayer.motion_offset.y = 2 * mod * relative_y
        
        $Layer2/ParallaxLayer.motion_offset.x = 3 * mod * relative_x
        $Layer2/ParallaxLayer.motion_offset.y = 3 * mod * relative_y
        
        $Layer3/ParallaxLayer.motion_offset.x = 4 * mod * relative_x
        $Layer3/ParallaxLayer.motion_offset.y = 4 * mod * relative_y
        
        $Layer4/ParallaxLayer.motion_offset.x = 8 * mod * relative_x
        $Layer4/ParallaxLayer.motion_offset.y = 8 * mod * relative_y


