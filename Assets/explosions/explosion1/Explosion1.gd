extends AnimatedSprite


var parent
var scaler = 1
var final_explosion = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func scaler(value):
    var scale = get_parent().get_scale()
    self.set_scale(Vector2(1/scale.x, 1/scale.y)/value) #2D
    
func begin():
    play()

func _on_Explosion1_animation_finished() -> void:
    queue_free()
    if final_explosion == true:
        get_parent().queue_free()
