extends Node2D

var shuttle = preload("res://Assets/Ship/Blender/Shuttle/Shuttle.tscn")
onready var positions = $s1/positions
var planet

var stage = 1
var stages = 4
var team_1_working = true
var team_2_working = true

var materials = 0
var completion = 0
var stage_completion = 250
var enough_time = false


var shuttle_capacity = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    nextWeld(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if materials >= 1 and completion < 1000:
        materials -= 1
        completion += 1
        stageUp()

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
    if completion >= stage * stage_completion and enough_time == true:
        stage += 1
        if stage == 2:
            positions = $s2/positions
            $s2.show()
            $s1.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 3:
            positions = $s3/positions
            $s3.show()
            $s2.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 4:
            positions = $s4/positions
            $s4.show()
            $s3.hide()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 5:
            positions = $s4/positions
            $s4.hide()
            $s5.show()
            nextWeld(3)
            shuttle_capacity = shuttle_capacity*stage
        elif stage == 6:
            $Team1/Particles2D.set_emitting(false)
            $Team2/Particles2D.set_emitting(false)
            $Team1.hide()
            $Team2.hide()
            $WeldTime.stop()
            $WeldTime2.stop()
            $projectTimer.stop()
            $Turret203.show()
            shuttle_capacity = shuttle_capacity*stage
        

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


func _on_projectTimer_timeout() -> void:
    enough_time = true


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
    var fields = get_tree().get_nodes_in_group("asteroid_fields")
    for field in fields:
        if global_position.distance_to(field.global_position) < 50000:
            return field.global_position

func _on_ShuttleTimer_timeout() -> void:
    spawnShuttle(findResource())
    $ShuttleTimer.set_wait_time(rand_range(15,45))


func _on_report_timeout() -> void:
    print("Space Station resources: ", materials, ". Completion:", completion/10, "%.")
