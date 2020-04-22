extends Node2D
var new_position = Vector2()
var planet = preload("res://Wells/Planet.tscn")
var rect = preload("res://GiantRect.tscn")
var sun = preload("res://Wells/Sun.tscn")
var aField = preload("res://Assets/Planets/Asteroids/AsteroidField.tscn")
var ships
var planet_count = 16
var gridY = sqrt(planet_count)
var gridX = sqrt(planet_count)
var gUnit = 60000
var map_center = Vector2(sqrt(planet_count)*(gUnit/2),sqrt(planet_count)*(gUnit/2))
var map_seed = "abcdefghijklmnopABCDEFGHIJKLMNOPqrstuvwxyzQRSTUVWXYZ"
var get_random = false
var randX = randi()%9001
var randY = randi()%9001



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    #Global.connect("player_landed", self, "onPlanet")
    Global.world = self
    Input.set_mouse_mode(1)
    Global.connect("torpedo_request", self, "issueTorpedo")
    Global.connect("request_planets", self, "sendPlanetPositions")
    Global.emit_signal("main_ready")
    Global._play = true
    print("Main is ready")
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
            var field_quant = rand_range(5,floor(175/planet_count)) #per tile
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
            
            #asteroid fields
            while field_quant > 0:
                field_quant -= 1
                var new_field = aField.instance()
                $Navigation2D/Bodies.add_child(new_field)
                new_field.global_position = grid_point - Vector2(gUnit/2,gUnit/2)
                getRandom(field_quant)
                new_field.global_position = (new_field.global_position - Vector2(20000,20000)) + Vector2(randX,randY)
                new_field.global_position.x = clamp(new_field.global_position.x, (grid_point.x)-(gUnit*.8), (grid_point.x)+(gUnit*.8))
                new_field.global_position.y = clamp(new_field.global_position.y, (grid_point.y)-(gUnit*.8), (grid_point.y)+(gUnit*.8))
                var distance_ok = false
                while distance_ok == false:
                    if Global.asteroidFamilies.size() > 0:
                        for field in Global.asteroidFamilies:
                            if new_field.global_position.distance_to(field.global_position) < 15000 and new_field.global_position.distance_to(new_planet.global_position) < 15000:
                                    new_field.global_position = (new_field.global_position - Vector2(20000,20000)) + Vector2(randX,randY)
                                    new_field.global_position.x = clamp(new_field.global_position.x, (grid_point.x)-(gUnit*.8), (grid_point.x)+(gUnit*.8))
                                    new_field.global_position.y = clamp(new_field.global_position.y, (grid_point.y)-(gUnit*.8), (grid_point.y)+(gUnit*.8))
                                    break
                        distance_ok = true
                    else:
                        break
                Global.asteroidFamilies.append(new_field)
            x += 1
        y += 1
    nameAsteroidFamilies()
    Global.emit_signal("map_ready")

func getRandom(cycle):
    var x = 0
    while x < 2*cycle:
        randomize()
        randX = randi()%40000
        randY = randi()%40000
        x += .314

func nameAsteroidFamilies():
    Global.asteroidNames()
    var named_families = []
    var num = float(Global.astNames.size())
    var den = float(Global.asteroidFamilies.size())
    var named_ratio = float(num/den)
    var aNames = Global.astNames
    for field in Global.asteroidFamilies:
        if aNames.size() == 1:
            var fName = aNames[0]
            field.family = fName
            named_families.append(field)
        elif aNames.size() > 1:
            var new_ran = abs(floor(rand_range(0,aNames.size()-1)))
            var fName = aNames[new_ran]
            aNames.erase(fName)
            field.family = fName
            named_families.append(field)
    print("asteroid families: ", Global.asteroidFamilies.size())
    Global.asteroidFamilies = named_families
    print("named asteroid families: ", Global.asteroidFamilies.size())
        
    








