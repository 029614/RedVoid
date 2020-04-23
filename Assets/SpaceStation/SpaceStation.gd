extends Node2D


onready var positions = $s1/positions

var stage = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    nextWeld(3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass

func nextWeld(team):
    var pos = positions.get_children()
    if team == 1:
        $Team1.position = pos[randi()%pos.size()].position
    elif team == 2:
        $Team2.position = pos[randi()%pos.size()].position
    elif team == 3:
        $Team2.position = pos[randi()%pos.size()].position
        $Team1.position = pos[randi()%pos.size()].position

func stageUp():
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
        $s4.hide()
        $s5.show()
        nextWeld(3)
    elif stage == 6:
        $Team1/Particles2D.set_emitting(false)
        $Team2/Particles2D.set_emitting(false)
        $Team1.hide()
        $Team2.hide()
        $WeldTime.stop()
        $WeldTime2.stop()
        $projectTimer.stop()
        $Turret203.show()
        

func _on_WeldTime_timeout() -> void:
    nextWeld(1)


func _on_projectTimer_timeout() -> void:
    stageUp()


func _on_WeldTime2_timeout() -> void:
    nextWeld(2)
