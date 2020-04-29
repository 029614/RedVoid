extends Control


onready var map_drp = $NewGame/Panel/VBoxContainer/Options/MapSize
onready var faction_drp = $NewGame/Panel/VBoxContainer/Options/Enemies
onready var difficulty_drp = $NewGame/Panel/VBoxContainer/Options/Difficulty
onready var color_list = $NewGame/Panel/VBoxContainer/Select/Color/color/Popup/VBoxContainer.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    map_drp.get_popup().add_check_item("Small")
    map_drp.get_popup().add_check_item("Medium")
    map_drp.get_popup().add_check_item("Large")
    map_drp.get_popup().add_check_item("Huge")
    
    difficulty_drp.get_popup().add_check_item("Easy")
    difficulty_drp.get_popup().add_check_item("Normal")
    difficulty_drp.get_popup().add_check_item("Hard")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass


func _on_New_pressed() -> void:
    $NewGame.popup_centered()
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_NewGame_popup_hide() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_Quit_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()
    get_tree().quit()


func _on_Host_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_Join_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_Start_pressed() -> void:
    Global.number_of_factions = $NewGame/Panel/VBoxContainer/Options/HBoxContainer/Enemies.value
    get_tree().change_scene("res://NewMain.tscn")
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_Load_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_School_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()


func _on_Settings_pressed() -> void:
    $Click.play(0.0)
    $Click/ClickTimer.start()








func _on_New_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_Load_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_Host_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_Join_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_School_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_Settings_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_Quit_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_BeepTimer_timeout() -> void:
    $Beep.stop()


func _on_Start_mouse_entered() -> void:
    $Beep.play(0.0)
    $Beep/BeepTimer.start()


func _on_ClickTimer_timeout() -> void:
    $Click.stop()


func _on_color_pressed() -> void:
    $NewGame/Panel/VBoxContainer/Select/Color/color/Popup.popup()
    var pos = $NewGame/Panel/VBoxContainer/Select/Color/color.get_global_position()
    $NewGame/Panel/VBoxContainer/Select/Color/color/Popup.set_global_position(Vector2(pos.x + 1, pos.y+25))


func _on_Blue_pressed() -> void:
    changeColor(0)


func _on_Yellow_pressed() -> void:
    changeColor(1)


func _on_Red_pressed() -> void:
    changeColor(2)


func _on_Ocean_pressed() -> void:
    changeColor(3)


func _on_Purple_pressed() -> void:
    changeColor(4)


func _on_Green_pressed() -> void:
    changeColor(5)
    
func changeColor(color):
    for c in color_list:
        c.show()
    color_list[color].hide()
    $NewGame/Panel/VBoxContainer/Select/Color/color.self_modulate = color_list[color].self_modulate
    $NewGame/Panel/VBoxContainer/Select/Color/color/Popup.hide()
    


