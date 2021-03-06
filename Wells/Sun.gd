extends Node2D

onready var mass =  planet_radius
var planet_radius = randi()%150+50
var moon_radius = planet_radius/4
export var mass_multiplyer = .75
export var _is_active_target = false
export var _is_destructive = false
var _is_active_takeoff = false
export var orbit_velocity = .2
var moon = false
var ownership = null
var orbit_assignment
onready var orbit = {$RotateMe/orbit1: false, $RotateMe/orbit2: false, $RotateMe/orbit3: false, $RotateMe/orbit4: false, $RotateMe/orbit5: false, $RotateMe/orbit6: false, $RotateMe/orbit7: false, $RotateMe/orbit8: false}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Global.connect("capture_planet", self, "capture")
    if randi()%3+1 == 1:
        moon = true
    var normal_scale = Vector2(1/get_scale().x, 1/get_scale().y)
    $Planet.set_scale(normal_scale)
    $Planet.set_position($Planet.get_position()*normal_scale)
    reName(name)
    mass = pow((mass * self.get_scale().x), 2) * mass_multiplyer
    planet_radius = planet_radius * self.get_scale().x
    print(self.name, " Mass: ", mass, " Radius: ", planet_radius)
    
    var lp = self.position
    var gp = self.global_position
    var mp = get_parent().get_parent().position
    var gp2 = mp + lp
    #print("lp, gp, mp,  gp2: ", lp, gp, mp, gp2)
    
    #print("Planet Radius, ", name, ": ", planet_radius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
    $RotateMe.rotation += orbit_velocity * delta

func readyTakeOff():
    self._is_active_takeoff = true
    $KinematicBody2D.hide()
    $Area2D/CollisionShape2D.disabled = true
    print("ready for takeoff!")

func takeOff():
    $KinematicBody2D.show()
    $Area2D/CollisionShape2D.set_disabled(false)

func reName(new_name):
    $Planet.set_text(new_name)

func constructionHandler(construction):
    for building in $Constructions.get_children():
        if construction == building.name:
            building.show()

func capture(faction, planet):
    if ownership != faction and planet == self:
        ownership = faction
        $FactionIndicator.set_modulate(Global.player_color)
    
func _on_Landing_area_shape_entered(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
    if Global.player_registry.has(area.get_parent()) and _is_destructive == true:
        Global.emit_signal("player_died")
    elif area.name == "LandingGear" and _is_destructive == false:
        Global.emit_signal("player_landed", self)
        print("player is landing")


func _on_Arrival_body_entered(body: Node) -> void:
    pass


func _on_Arrival_body_exited(body):
    pass
