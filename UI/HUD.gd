extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#    pass





# These only change characters on the HUD - No real game impact

#Changes fire mode indicator
func set_fire_mode(fire_mode):
    pass

#returns current firemode
func get_fire_mode():
    pass

#sets the fuel gauge current value and max value
func set_fuel(fuel, fuel_max):
    $Vitals/FuelGauge.set_value(fuel)
    if fuel_max and $Vitals/FuelGauge.get_max() != fuel_max:
        $Vitals/FuelGauge.set_max(fuel_max)

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
    pass

#returns a list of all messages
func get_messages():
    pass

#sets the warning message
func set_warning(warning):
    pass

#returns a list of all warning messages
func get_warnings():
    pass




