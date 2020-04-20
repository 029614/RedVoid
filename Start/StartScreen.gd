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
    $MainMenu.hide()


func _on_NewGame_popup_hide() -> void:
    $MainMenu.show()


func _on_Quit_pressed() -> void:
    get_tree().quit()


func _on_Host_pressed() -> void:
    pass # Replace with function body.


func _on_Join_pressed() -> void:
    pass # Replace with function body.


func _on_Start_pressed() -> void:
    get_tree().change_scene("res://NewMain.tscn")
