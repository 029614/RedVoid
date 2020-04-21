extends Node2D
var new_position = Vector2()
onready var player = $Factions/Faction/Actor
var ships


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Global.connect("player_landed", self, "onPlanet")
    Input.set_mouse_mode(1)
    Global.connect("torpedo_request", self, "issueTorpedo")
    Global.connect("request_planets", self, "sendPlanetPositions")
    Global.emit_signal("main_ready")
    Global._play = true
    print("Main is ready")
    Global.world = self
    print(Global.world)
    Global.bodies = $Navigation2D/Bodies.get_children()
    
    #$Freighter.goTo(bodies.get_node("Planet5"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    pass
        

func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("Quit"):
        get_tree().quit()

func placeTarg(loc, title):
    pass
    
func command(command):
    if command == "/restart":
        get_tree().reload_current_scene()
        return
    if command == "/refuel":
        player.fuel = player.fuel_cap
    if command == "/killAll":
        ships = get_tree().get_nodes_in_group("ship")
        destroyAll(ships)

func destroyAll(things):
    print("yay")
    for ship in things:
        ship.queue_free()
