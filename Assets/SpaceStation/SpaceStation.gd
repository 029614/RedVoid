extends Node2D

var shuttle = preload("res://Assets/Ship/Blender/Shuttle/Shuttle.tscn")
var oGun = preload("res://Assets/SpaceStation/OrbitalGun/OrbitalGun.tscn")
var sYard = preload("res://Assets/SpaceStation/ShipYard/ShipYard.tscn")
onready var positions = $Stages/s1/positions
var planet

var stage = 1
var stages = 6
var team_1_working = true
var team_2_working = true

var materials = 2000
var completion = 0
var stage_completion = 250
var enough_time = false

var health = 100


var shuttle_capacity = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    nextWeld(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if materials >= 1 and completion < stage_completion*stages:
        materials -= 1
        completion += 1
        stageUp()
    
    if health <= 0:
        self.queue_free()

func nextWeld(team):
    var pos = positions.get_children()
    if team == 1:
        $Team1.global_position = pos[randi()%pos.size()].global_position
    elif team == 2:
        $Team2.global_position = pos[randi()%pos.size()].global_position
    elif team == 3:
        $Team2.global_position = pos[randi()%pos.size()].global_position
        $Team1.global_position = pos[randi()%pos.size()].global_position

func stageUp():
    if completion >= stage * stage_completion:
        stage += 1
        if stage == 2:
            positions = $Stages/s2/positions
            $Stages/s2.show()
            $Stages/s1.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 3:
            positions = $Stages/s3/positions
            $Stages/s3.show()
            $Stages/s2.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 4:
            positions = $Stages/s4/positions
            $Stages/s4.show()
            $Stages/s3.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 5:
            positions = $Stages/s5/positions
            $Stages/s4.hide()
            $Stages/s5.show()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 6:
            positions = $Stages/s6/positions
            $Stages/s5.hide()
            $Stages/s6.show()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 7:
            $Stages/s6.hide()
            $Stages/s7.show()
            $Team1/Particles2D.set_emitting(false)
            $Team2/Particles2D.set_emitting(false)
            $Team1.hide()
            $Team2.hide()
            $WeldTime.stop()
            $WeldTime2.stop()
            shuttle_capacity = shuttle_capacity*stage
            build(sYard)
            build(oGun)
        

func _on_WeldTime_timeout() -> void:
    var switch = randi()%11
    if switch%2 == 0 and team_1_working == true:
        $Team1/Particles2D.set_emitting(false)
        $Team1/Corona.hide()
        team_1_working = false
        $WeldTime.set_wait_time(rand_range(.3,3))
    elif switch%2 == 0 and team_1_working == false:
        $Team1/Particles2D.set_emitting(true)
        $Team1/Corona.show()
        team_1_working = true
        $WeldTime2.set_wait_time(rand_range(.3,3))
    else:
        $Team1/Particles2D.set_emitting(true)
        $Team1/Corona.show()
        team_1_working = true
        $WeldTime2.set_wait_time(rand_range(.3,3))
        nextWeld(1)


func _on_WeldTime2_timeout() -> void:
    var switch = randi()%11
    if switch%2 == 0 and team_2_working == true:
        $Team2/Particles2D.set_emitting(false)
        $Team2/Corona.hide()
        team_2_working = false
        $WeldTime2.set_wait_time(rand_range(.3,3))
    elif switch%2 == 0 and team_2_working == false:
        $Team2/Particles2D.set_emitting(true)
        $Team2/Corona.show()
        team_2_working = true
        $WeldTime2.set_wait_time(rand_range(.3,3))
    else:
        $Team2/Particles2D.set_emitting(true)
        $Team2/Corona.show()
        team_2_working = true
        $WeldTime2.set_wait_time(rand_range(.3,3))
        nextWeld(2)

func spawnShuttle(target):
    if $Shuttles.get_child_count() < shuttle_capacity:
        var new_shuttle = shuttle.instance()
        $Shuttles.add_child(new_shuttle)
        new_shuttle.position = Vector2(rand_range(0,100),rand_range(0,100))
        new_shuttle.base_pos = self.global_position
        new_shuttle.base = self
        new_shuttle.job(target)

func findResource():
    print("finding resource")
    var count = 0
    var tgroup
    var fields
    for group in planet.get_groups():
        if group != "planets":
            tgroup = group
    fields = get_tree().get_nodes_in_group("asteroid_fields_" + tgroup)
    print("asteroid fields: ", fields)
    var closest = Global.getClosest(self, fields, global_position)
    print("closest asteroid field: ", closest)
    return closest

func _on_ShuttleTimer_timeout() -> void:
    spawnShuttle(findResource())
    $ShuttleTimer.set_wait_time(rand_range(15,45))


func _on_report_timeout() -> void:
    pass
    #print("Space Station resources: ", materials, ". Completion:", completion/10, "%.")

func build(construction):
    var new = construction.instance()
    new.planet = planet
    new.station = self
    planet.get_node("Constructions").add_child(new)
    new.global_position = survey()

func survey():
    var begin = planet.global_position - Vector2(5000,5000)
    var end = planet.global_position + Vector2(5000,5000)
    var location = Vector2(rand_range(begin.x, end.x), rand_range(begin.y,end.y))
    while location.distance_to(planet.global_position) < 2500:
        location = Vector2(rand_range(begin.x, end.x), rand_range(begin.y,end.y))
    return location



