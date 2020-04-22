extends Node2D
var new_position = Vector2()
var planet = preload("res://Wells/Planet.tscn")
var rect = preload("res://GiantRect.tscn")
var sun = preload("res://Wells/Sun.tscn")
var ships
var planet_count = 16
var gridY = sqrt(planet_count)
var gridX = sqrt(planet_count)
var gUnit = 60000
var map_seed = "abcdefghijklmnopABCDEFGHIJKLMNOPqrstuvwxyzQRSTUVWXYZ"
var get_random = false
var randX = randi()%9001
var randY = randi()%9001



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
    createMap()
    
    #$Freighter.goTo(bodies.get_node("Planet5"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    pass
        

func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("Quit"):
        get_tree().quit()
    
func command(command, player):
    if command == "/restart":
        get_tree().reload_current_scene()
        return
    if command == "/refuel":
        player.ship.fuel = player.ship.fuel_cap
    if command == "/killAll":
        ships = get_tree().get_nodes_in_group("ship")
        destroyAll(ships)

func destroyAll(things):
    print("yay")
    for ship in things:
        ship.queue_free()

func createMap():
    get_random = true
    print("gridX: ",gridX, " gridY: ",gridY )
    var start_point = Vector2(gUnit,gUnit)
    var end_point = Vector2(gridX*gUnit,gridY*gUnit)
    var grid_point = start_point
    var y = 1
    var new_sun = sun.instance()
    $Navigation2D/Bodies.add_child(new_sun)
    new_sun.global_position = end_point/2
    while y <= gridY:
        var x = 1
        grid_point = Vector2()
        while grid_point.x < end_point.x:
            grid_point = Vector2(gUnit*x,gUnit*y)
            var new_planet = planet.instance()
            var new_rect = rect.instance()
            $Navigation2D/Bodies.add_child(new_planet)
            $Navigation2D/Bodies.add_child(new_rect)
            new_rect.global_position = grid_point - Vector2(gUnit,gUnit)
            new_planet.global_position = grid_point - Vector2(gUnit/2,gUnit/2)
            getRandom(y)
            new_planet.global_position = (new_planet.global_position - Vector2(20000,20000)) + Vector2(randX,randY)
            new_planet.grid = new_rect
            #while new_planet.global_position.distance_to(new_sun.global_position) < 2000 and new_planet.global_position.distance_to(grid_point-(Vector2(gUnit/2,gUnit/2))) > 5000:
            #    new_planet.global_position = grid_point - Vector2(randi()%15001,randi()%15001)
            print("calculating position: ", x, ",", y, " grid point: ", grid_point)
            x += 1
        y += 1

func getRandom(cycle):
    var x = 0
    while x < 2*cycle:
        randomize()
        randX = randi()%40000
        randY = randi()%40000
        x += .314
        
    








