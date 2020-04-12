extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var timer = Timer.new()
    timer.connect("timeout",self,"_on_timer_timeout") 
    #timeout is what says in docs, in signals
    #self is who respond to the callback
    #_on_timer_timeout is the callback, can have any name
    add_child(timer) #to process
    timer.set_wait_time( 5 )
    timer.start() #to start
    timer.connect("timeout", self, "_on_Timer_timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass
func _on_Timer_timeout():
    self.queue_free()
