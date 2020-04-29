extends Sprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var mass = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass



func _on_AsteroidField_area_entered(area: Area2D) -> void:
    if area.name == "Mouse":
        get_parent().scale = get_parent().scale*1.2
        get_parent().modulate = Color8(0,82,255,150)


func _on_AsteroidField_area_exited(area: Area2D) -> void:
    pass # Replace with function body.
