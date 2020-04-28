extends Node

# Statsy (STAY - SEE) the state's woman
# Core behaviors: Refueling, Attacking Planets, Defending Planets, Defending Freighters, Attacking Freighters, Attacking Enemy

var black_box = {} # Records all query's

func query(combatant, entity_id, entity_state): # true or false, reference to the entity, dictionary of entity's states
    pass

func get_black_box():
    return black_box
