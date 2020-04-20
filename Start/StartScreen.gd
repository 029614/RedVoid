extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


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
