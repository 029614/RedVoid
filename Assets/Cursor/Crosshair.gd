extends Node2D


var hidden = false
var alpha = 100


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    $Outer.rotation += .005
    $Inner.rotation -= .01
    $Mouse.name = "Mouse"

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if hidden == true:
            self.modulate = Color8(255,255,255,255)
        self.position = get_viewport().get_mouse_position()
        $Timer.start(4)


func _on_Timer_timeout() -> void:
    self.modulate = Color8(255,255,255,alpha)
    hidden = true
    


func _on_Mouse_area_entered(area: Area2D) -> void:
    if area.name == "AsteroidField":
        area.get_parent().scale = get_parent().scale*1.2
        area.get_parent().modulate = Color8(0,82,255,150)


func _on_Mouse_area_exited(area: Area2D) -> void:
    if area.name == "AsteroidField":
        area.get_parent().scale = get_parent().scale/2
        area.get_parent().modulate = Color8(189,189,189,100)
