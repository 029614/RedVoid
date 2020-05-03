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

func fire(mode):
    if mode == true:
        $AudioStreamPlayer2D.play(0.0)
        $Particles2D.set_emitting(true)
        $Particles2D2.set_emitting(true)
    elif mode == false:
        $AudioStreamPlayer2D.stop()
        $Particles2D.set_emitting(false)
        $Particles2D2.set_emitting(false)
        
