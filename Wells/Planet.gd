extends Node2D

onready var player = get_parent().get_parent().get_parent().get_node("Faction/Actor")
onready var freighter = get_parent().get_parent().get_parent().get_node("Freightor")

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
onready var orbit = {$RotateMe/orbit1: false, $RotateMe/orbit2: false, $RotateMe/orbit3: false, $RotateMe/orbit4: false, $RotateMe/orbit5: false, $RotateMe/orbit6: false, $RotateMe/orbit7: false, $RotateMe/orbit8: false}

var capture_perc = 0
var capturing_fac = null


# Planet states
var planet_states = ["empty", "occupied", "being_captured"]
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
    print(self.name, " Mass: ", mass, " Radius: ", planet_radius)
    
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
            print(capture_perc)
            $Prog/CaptureProgress.set_value(capture_perc)
        elif capture_perc >= 100:
            capture_perc = 100
            planet_state = "occupied"
            capture(capturing_fac, self)
            capturing_fac = null
            $Prog/CaptureProgress/Unclaimed.hide()
            print("successful capture")
    
    if planet_state == "empty" and capture_perc > 0:
        print("planet empty")
        capture_perc -= .5

func capture(faction, planet):
    if ownership != faction and planet == self:
        ownership = faction
        faction.planets.append(self)
        var message = str(planet.name) + " has been captured by " + str(faction.name) + "."
        Global.messageAll(message)
    
func _on_Landing_area_shape_entered(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
    if Global.player_registry.has(area.get_parent()) and _is_destructive == true:
        Global.emit_signal("player_died")
    elif area.name == "LandingGear" and _is_destructive == false:
        area.get_parent().location_state = "landing"
        area.get_parent().pilot.planet = self
        planet_state = "being_captured"
        capturing_fac = area.get_parent().pilot.faction
        print("lalala")

func _on_Arrival_body_entered(body: Node) -> void:
    print(body)
    if body.get("pilot"):
        body.pilot.planet = self
        body.pilot.orbit = orbit


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



func _on_Landing_area_shape_exited(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
    if planet_state != "occupied":
        planet_state = "empty"
