# Currently Autoloaded as DeckData
tool
extends Node


# Emitted when the value for deck_theme changes.
signal deck_theme_changed();


# 
export var deck_visual_data: Resource setget _set_deck_visual_data;

# 
var deck_theme: DeckVisualData;


# 
func _set_deck_visual_data(deck_visual_data_: Resource) -> void:
	deck_visual_data = deck_visual_data_;
	if (deck_visual_data is DeckVisualData):
		deck_theme = deck_visual_data;
	else:
		deck_theme = null;
	
	emit_signal("deck_theme_changed");
