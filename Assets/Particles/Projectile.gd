extends KinematicBody2D


var velocity = Vector2()
var projectile_speed = 1500
var projectile_direction = 0.0


func _ready() -> void:
    var timer = Timer.new()
    timer.connect("timeout",self,"_on_timer_timeout") 
    #timeout is what says in docs, in signals
    #self is who respond to the callback
    #_on_timer_timeout is the callback, can have any name
    add_child(timer) #to process
    timer.set_wait_time( 1.25 )
    timer.start() #to start
    timer.connect("timeout", self, "_on_Timer_timeout")
    velocity += Vector2(1, 0).rotated(projectile_direction).normalized()*projectile_speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    velocity = move_and_slide(velocity)


func _on_Timer_timeout():
    self.queue_free()


func _on_Area2D_body_entered(body: Node) -> void:
    pass

func setVector(rot, speed):
    projectile_direction = rot
    projectile_speed += speed
