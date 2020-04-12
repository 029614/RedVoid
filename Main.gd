extends Node2D
onready var player = $Actor
onready var bodies = $Navigation2D/Bodies
var target = preload("res://Target.tscn")
var new_position = Vector2()
var _move_camera = false
var torpedo = preload("res://Assets/Particles/Projectile.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Global.connect("player_landed", self, "onPlanet")
    Global.connect("torpedo_request", self, "issueTorpedo")
    Global.connect("request_planets", self, "sendPlanetPositions")
    Global.emit_signal("main_ready")
    Global._play = true
    print("Main is ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
        

func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("Quit"):
        get_tree().quit()

func placeTarg(loc, title):
    var t = target.instance()
    t.get_node("Planet").set_text(title)
    self.add_child(t)
    t.set_global_position(loc)

func sendPlanetPositions():
    print("preparing planets")
    var pos = []
    for body in bodies.get_children():
        pos.append(body.get_position())
    Global.emit_signal("send_planets", pos)

func issueTorpedo(party):
    var e = torpedo.instance()
    add_child(e)
    e.setVector(player.rotation, player.current_speed)
    e.set_global_position(player.gun_coords.get_global_position())
    #e.projectile_speed += current_speed
