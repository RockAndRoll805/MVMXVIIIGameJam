extends Node

signal InWorldItem_collected(item_type) #Player listening for collision with InWorldItems
signal damage_dealt(amount) #Actors and hazards emit
signal damage_taken(amount) #Actors listening
