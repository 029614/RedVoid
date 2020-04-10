extends Node2D
onready var player = $Actor
onready var bodies = $Navigation2D/Bodies
var target = preload("res://Target.tscn")
var new_position = Vector2()
var _move_camera = false
#onready var overlay_origin = $overlay.get_position()
#onready var overlay = $overlay
#onready var new_aust = get_node("Bodies/New Austrailia")
#onready var new_zea = get_node("Bodies/New New Zealand")
#onready var sun = get_node("Bodies/Sun")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Global.connect("player_landed", self, "onPlanet")
    Global.connect("request_planets", self, "sendPlanetPositions")
    Global.emit_signal("main_ready")
    print("Main is ready")
    #$CanvasLayer/UI/ProgressBar.set_max(player.fuel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #$CanvasLayer/UI/Frames/Label.set_text(str(Engine.get_frames_per_second()))
    #$CanvasLayer/UI/ProgressBar.set_value(player.fuel)
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

func _on_newAust_pressed() -> void:
    #$Freightor.goTo(new_aust)
    pass


func _on_newZea_pressed() -> void:
    #$Freightor.goTo(new_zea)
    pass


func _on_Sun_pressed() -> void:
    #$Freightor.goTo(sun)
    pass


func _on_Stop_pressed() -> void:
    #$Freightor.stop()
    pass
