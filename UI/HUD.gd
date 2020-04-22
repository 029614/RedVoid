extends Control

onready var player = get_parent().get_parent()
var enemy_icon = preload("res://Assets/Ship/MapIconEnemy.tscn")

var blink_speed = 5
var red_alpha = 130

var icons_active = false
var field_names = false

var icons = []
var tracking = []

var field_labels = []

var cannon = "stopped"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Global.connect("map_ready", self, "asteroidLabels")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if player.camera_state and player.camera_state == "zoomed_out" and icons_active == false:
        activateIcons()
        print(player.camera_state, icons_active)
    elif player.camera_state != "zoomed_out" and icons_active == true:
        deactivateIcons()
        print(player.camera_state, icons_active)
    
    if icons_active == true:
        var count = 0
        for icon in icons:
            icon.global_position = tracking[count].global_position
            count += 1
        
    
    

func _input(event: InputEvent) -> void:
    
    if Input.is_action_just_released("compose_message"):
        if get_focus_owner() == $ConsoleBottom/ReadOut/LineInput:
            pass
        else:
            $ConsoleBottom/ReadOut/LineInput.grab_focus()
            $ConsoleBottom/ReadOut/LineInput.clear()



func fuelWarning():
    if red_alpha == 50:
        blink_speed = -5
    elif red_alpha == 180:
        blink_speed = 5
    $ConsoleFuel/FuelGauge.set_self_modulate(Color8(253,50,40,red_alpha-blink_speed))
    $ConsoleFuel/FuelGauge.get_node("Label").set_self_modulate(Color8(253,50,40,red_alpha-blink_speed))
    red_alpha -= blink_speed
        

# These only change characters on the HUD - No real game impact

#Changes fire mode indicator
func set_fire_mode(fire_mode):
    pass

#returns current firemode
func get_fire_mode():
    pass

#sets the fuel gauge current value and max value
func set_fuel(fuel, fuel_max):
    $ConsoleFuel/FuelGauge.set_value(fuel)
    if fuel_max and $Vitals/FuelGauge.get_max() != fuel_max:
        $ConsoleFuel/FuelGauge.set_max(fuel_max)

#returns the current fuel display as fuel/fuel_max
func get_fuel():
    pass

#Sets the ammo counter for the Cannon
func set_ammo_count(ammo_count):
    $Weapons/VBoxContainer/Guns.set_text(str(ammo_count))

#returns the value of the ammo counter for the Cannon
func get_ammo_count():
    pass

#Set the missile counter
func set_missile_count(missile_count):
    $PanelRight/VBoxContainer/Missile.set_text(str(missile_count))

#returns the value of the missile counter
func get_missile_count():
    pass

#sets the bomb counter
func set_bomb_count(bomb_count):
    $Weapons/VBoxContainer/Bombs.set_text(str(bomb_count))

#gets the value of the bomb counter    
func get_bomb_count():
    pass

#sets the state of the missile warning LED to on = true, or off = false
func set_missile_warning(state):
    pass

#returns the value of the missile warning LED: on = true, or off = false
func get_missile_warning():
    pass

#sets the state of the radar warning LED to on = true, or off = false
func set_radar_warning(state):
    pass

#returns the state of the missile warning LED: on = true, or off = false
func get_radar_warning():
    pass

#sets the shields indicator value as a percentage 
func set_shields(shields, shields_max):
    pass

#returns the shields indicator value as a percentage
func get_shields():
    pass

#adds a message to the message panel
func set_message(message):
    var l = Label.new()
    l.set_text(message)
    l.set_custom_minimum_size(Vector2(530, 0))
    l.set_autowrap(true)
    $ConsoleBottom/ReadOut/ScrollContainer/VBoxContainer.add_child(l)

#returns a list of all messages
func get_messages():
    pass

#sets the warning message
func set_warning(warning):
    pass

#returns a list of all warning messages
func get_warnings():
    pass






func _on_LineInput_text_entered(new_text: String) -> void:
    if new_text.begins_with("/"):
        Global.world.command(new_text, player)
        $ConsoleBottom/ReadOut/LineInput.clear()
        $ConsoleBottom/ReadOut/LineInput.set_focus_mode(0)
        $ConsoleBottom/ReadOut/LineInput.set_focus_mode(1)
    else:
        var t = "Player: " + new_text
        set_message(t)
        $ConsoleBottom/ReadOut/LineInput.clear()
        $ConsoleBottom/ReadOut/LineInput.set_focus_mode(0)
        $ConsoleBottom/ReadOut/LineInput.set_focus_mode(1)
    beep()


func activateIcons():
    icons = []
    for ship in get_tree().get_nodes_in_group("ship"):
        if ship != player.ship:
            var t = enemy_icon.instance()
            t.name = ship.name
            $Ships.add_child(t)
            t.global_position = ship.global_position
            t.global_scale = Vector2(3,3)
            icons_active = true
            icons.append(t)
            if tracking.has(ship) == false:
                tracking.append(ship)
            print("icons activated")
            print("currently active indicators: ", $Ships.get_children())
    for field in field_labels:
        field.show()

func deactivateIcons():
    for child in $Ships.get_children():
        child.queue_free()
    icons_active = false
    for field in field_labels:
        field.hide()

func asteroidLabels():
    for ast in Global.asteroidFamilies:
        var l = Label.new()
        var n = Node2D.new()
        if typeof(ast.family) == TYPE_STRING:
            l.set_text(ast.family + " Field")
        $Asteroids.add_child(n)
        n.add_child(l)
        n.global_position = ast.global_position
        field_labels.append(n)
        field_names = true
        n.set_scale(Vector2(50,50))
    print("field labels: ", field_labels)
    

func beep():
    $Sounds/Beep.play(0.0)
    $Sounds/Beep/BeepTimer.start()

func cannon(value):
    if value == true and cannon == "stopped":
        $Sounds/Cannon.play(0.0)
        cannon = "playing"
    elif value == false and cannon == "playing":
        $Sounds/Cannon.stop()
        cannon = "stopped"

func _on_BeepTimer_timeout() -> void:
    $Sounds/Beep.stop()





func _on_HideButton_toggled(button_pressed: bool) -> void:
    if button_pressed == true:
        $ConsoleBottom.set_size(Vector2($ConsoleBottom.get_size().x,137))
        $ConsoleBottom.set_position(Vector2($ConsoleBottom.get_position().x,$ConsoleBottom.get_position().y + 171))
        $ConsoleBottom/HideButton.set_text("Show")
    elif button_pressed == false:
        $ConsoleBottom.set_size(Vector2($ConsoleBottom.get_size().x,308))
        $ConsoleBottom.set_position(Vector2($ConsoleBottom.get_position().x,$ConsoleBottom.get_position().y - 171))
        $ConsoleBottom/HideButton.set_text("Hide")
