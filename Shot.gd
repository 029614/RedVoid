extends RigidBody2D


var projectile_speed = 1500
var gun_speed = 0
var lifetime = 1
var shooter = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var t = Timer.new()
    t.set_wait_time(lifetime)
    t.connect("timeout", self, "bulletExpire")
    t.start()
    apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
    #apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))


func _on_Area2D_body_entered(body: Node) -> void:
    if Global.player_registry.has(body) and body != shooter:
        body.shields -= 5
        self.queue_free()

func bulletExpire():
    self.queue_free()
