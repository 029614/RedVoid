extends Node2D

onready var positions = $s1/positions
var planet
var station

var stage = 1
var stages = 6
var team_1_working = true
var team_2_working = true

var materials = 0
var completion = 0
var stage_completion = 125

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    nextWeld(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if station.materials >= .1 and completion < stages*stage_completion:
        station.materials -= .1
        completion += .1
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
    if completion >= stage * stage_completion:
        stage += 1
        if stage == 2:
            positions = $s2/positions
            $s2.show()
            $s1.hide()
            nextWeld(3)
        elif stage == 3:
            positions = $s3/positions
            $s3.show()
            $s2.hide()
            nextWeld(3)
        elif stage == 4:
            positions = $s4/positions
            $s4.show()
            $s3.hide()
            nextWeld(3)
        elif stage == 5:
            positions = $s5/positions
            $s5.show()
            $s4.hide()
            nextWeld(3)
        elif stage == 6:
            positions = $s6/positions
            $s6.show()
            $s5.hide()
            nextWeld(3)
        elif stage == 7:
            $s7.show()
            $s6.hide()
            $Team1/Particles2D.set_emitting(false)
            $Team2/Particles2D.set_emitting(false)
            $Team1.hide()
            $Team2.hide()
            $WeldTime.stop()
            $WeldTime2.stop()
            for gun in $Guns.get_children():
                gun.show()
            station.build(station.oGun)
        

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
