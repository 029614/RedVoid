extends Node2D

onready var player = get_parent().get_parent().get_parent().get_node("Faction/Actor")
onready var freighter = get_parent().get_parent().get_parent().get_node("Freightor")
var station = preload("res://Assets/SpaceStation/SpaceStation.tscn")

onready var mass =  planet_radius
var planet_radius = randi()%150+50
var moon_radius = planet_radius/4
export var mass_multiplyer = .75
export var _is_active_target = false
export var _is_destructive = false
var _is_active_takeoff = false
export var orbit_velocity = .1
var moon = false
var ownership = null
var orbit_assignment
var grid
onready var orbit = {$RotateMe/orbit1: false, $RotateMe/orbit2: false, $RotateMe/orbit3: false, $RotateMe/orbit4: false, $RotateMe/orbit5: false, $RotateMe/orbit6: false, $RotateMe/orbit7: false, $RotateMe/orbit8: false}

var capture_perc = 0
var capturing_fac = null

# Planet_resources
export var hydrogen = false
export var iron = false
export var carbon = false
export var radioisotope = false
export var lithium = false
export var silicon = false
export var conductive_metals = false
export var platinum = false
export var lead = false
export var tungsten = false
onready var resource_list = {"hydrogen":hydrogen, "iron":iron, "carbon":carbon, "radioisotope":radioisotope, "lithium":lithium, "silicon":silicon, "conductive_metals":conductive_metals, "platinum":platinum, "lead":lead, "tungsten":tungsten}

var resource_store = {"hydrogen":0, "iron":0, "carbon":0, "radioisotope":0, "lithium":0, "silicon":0, "conductive_metals":0, "platinum":0, "lead":0, "tungsten":0}


# Planet states
var planet_states = ["empty", "occupied", "being_captured", "colonized"]
var planet_state = "empty"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Global.connect("capture_planet", self, "capture")
    if randi()%3+1 == 1:
        moon = true
    var normal_scale = Vector2(1/get_scale().x, 1/get_scale().y)
    $Prog/Planet.set_scale(normal_scale)
    $Prog/Planet.set_position($Prog/Planet.get_position()*normal_scale)
    mass = pow((mass * self.get_scale().x), 2) * mass_multiplyer
    planet_radius = planet_radius * self.get_scale().x
    #print(self.name, " Mass: ", mass, " Radius: ", planet_radius)
    
    var lp = self.position
    var gp = self.global_position
    var mp = get_parent().get_parent().position
    var gp2 = mp + lp
    look_at(get_parent().get_node("Sun").get_global_position())
    $Prog.global_rotation = 0
    #print("lp, gp, mp,  gp2: ", lp, gp, mp, gp2)
    
    #print("Planet Radius, ", name, ": ", planet_radius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    $RotateMe.rotation += orbit_velocity * delta
    
    #Capturing
    if planet_state == "being_captured" :
        if capture_perc < 100.0:
            capture_perc += .1
            #print(capture_perc)
            $Prog/CaptureProgress.set_value(capture_perc)
        elif capture_perc >= 100:
            capture_perc = 100
            capture(capturing_fac, self)
            capturing_fac = null
            #print("successful capture")
    
    if planet_state == "empty" and capture_perc > 0:
        #print("planet empty")
        capture_perc -= .5
    
    if planet_state == "colonized":
        resourceTurn()

func capture(faction, planet):
    if ownership != faction and planet == self:
        ownership = faction
#        faction.planets.append(self)
        var message = str(planet.name) + " has been captured by " + str(faction.name) + "."
        $Prog/CaptureProgress.self_modulate = faction.faction_color_alpha
        $Prog/CaptureProgress/Unclaimed.hide()
        $Prog/CaptureProgress/Unclaimed.self_modulate = ownership.faction_color_alpha
        planet_state = "occupied"
        grid.modulate = faction.faction_color_alpha
        Global.messageAll(message)
        beginSpaceStation()

func changeOwnership(faction):
    ownership = faction
    $Prog/CaptureProgress.self_modulate = faction.faction_color_alpha
    $Prog/CaptureProgress/Unclaimed.hide()
    $Prog/CaptureProgress/Unclaimed.self_modulate = ownership.faction_color_alpha
    grid.modulate = faction.faction_color_alpha
    $Prog/CaptureProgress.set_value(100)
    planet_state = "occupied"
    beginSpaceStation()

func _on_Arrival_body_entered(body: Node) -> void:
    #print(body)
    if body.get("pilot"):
        body.pilot.planet = self
        body.pilot.orbit = $RotateMe


func _on_Arrival_body_exited(body):
    if body.get("pilot"):
        body.pilot.planet = null
        body.pilot.orbit = null



# Getters and Setters

func set_planet_name(new_name):
    pass

func get_planet_name():
    pass



func set_planet_faction(new_faction):
    pass

func get_planet_faction():
    pass



func set_destructible(value):
    pass

func get_destructible():
    pass



func set_planet_color(color):
    pass

func get_planet_color():
    pass


func resourceTurn():
    for resource in resource_list.keys():
        if resource_list.resource == true:
            resource_store.resource += 1
            

func _on_Landing_area_shape_exited(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
    if planet_state != "occupied":
        planet_state = "empty"

func beginSpaceStation():
    var new_station = station.instance()
    new_station.planet = self
    $SpaceStation.add_child(new_station)
    new_station.Stimer.start()
