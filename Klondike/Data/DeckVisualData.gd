# This is a fairly verbose way of handling this, I guess; but, I want to ensure that each card
# asset is actually handled by the Engine/Editor so I don't have to manage string paths anywhere.
tool
class_name DeckVisualData extends Resource


# Dictionary<String, CardVisualData>
var deck_card_visual_data: Dictionary = {};


# Returns the property string for the given card.
static func get_property_name_for(card: Card) -> String:
	var style_category: Array = [
		CardInfo.FaceValue.BACKSIDE, CardInfo.FaceValue.EMPTY,
	];
	
	if (card.face_value in style_category):
		if (card.face_value == CardInfo.FaceValue.BACKSIDE):
			return "card_style_back";
		
		return "card_style_empty";
	
	
	var special_category: Array = [
		CardInfo.FaceValue.JOKER_RED, CardInfo.FaceValue.JOKER_BLACK,
	];
	
	if (card.face_value in special_category):
		if (card.card_colour == CardInfo.CardColour.RED):
			return "card_special_joker_red";
		else:
			return "card_special_joker_black";
	
	
	return "card_%s_%s" % [
		CardInfo.Suit.find_key(card.suit).to_lower(),
		CardInfo.FaceValue.find_key(card.face_value).to_lower(),
	];


# 
func _create_card_visual_data_property_dict(card_name: String) -> Dictionary:
	return {
		"name": card_name,
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
		#"hint_string": "Resource",
		"usage": PROPERTY_USAGE_DEFAULT
	};


# 
func _populate_suit_and_value_for(property: String, card_data: CardVisualData) -> void:
	var prop_parts: Array = property.split("_", false);
	assert(prop_parts[0] == "card");
	var card_category: String = prop_parts[1];
	var card_name: String = prop_parts[2];
	
	var card_suit: int = CardInfo.Suit.NONE;
	var card_value: int = CardInfo.FaceValue.EMPTY;
	
	match (card_category):
		"style":
			if (card_name == "back"):
				card_value = CardInfo.FaceValue.BACKSIDE;
			elif (card_name == "empty"):
				card_value = CardInfo.FaceValue.EMPTY;
		"hearts", "spades", "diamonds", "clubs":
			card_suit = CardInfo.Suit.get(card_category.to_upper(), CardInfo.Suit.NONE);
			card_value = CardInfo.FaceValue.get(card_name.to_upper(), CardInfo.FaceValue.EMPTY);
		"special":
			if (card_name == "joker"):
				var color_string: String = prop_parts[3];
				var card_colour: int = \
					CardInfo.CardColour.RED if (color_string == "red") else CardInfo.CardColour.BLACK;
				if (card_colour == CardInfo.CardColour.RED):
					card_value = CardInfo.FaceValue.JOKER_RED;
				else:
					card_value = CardInfo.FaceValue.JOKER_BLACK;
		_:
			assert(false, "Unknown card cateogry!");
	# End match
	
	card_data.suit = card_suit;
	card_data.value = card_value;


# 
func _get_property_list() -> Array:
	var props: Array = [];
	props.append({"name": "Deck Visuals", "type": TYPE_NIL, "usage": PROPERTY_USAGE_CATEGORY});
	props.append({
		"name": "Card Style", "hint_string": "card_style_",
		"type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP,
	});
	props.append(_create_card_visual_data_property_dict("card_style_back"));
	props.append(_create_card_visual_data_property_dict("card_style_empty"));
	
	for suit in range(CardInfo.Suit.HEARTS, CardInfo.Suit.CLUBS + 1):
		var suit_name: String = CardInfo.Suit.find_key(suit).to_lower();
		props.append({
			"name": suit_name, "hint_string": "card_%s_" % suit_name,
			"type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP,
		});
		for value in range(CardInfo.FaceValue.ACE, CardInfo.FaceValue.KING + 1):
			props.append(_create_card_visual_data_property_dict(
				"card_%s_%s"
				% [suit_name, CardInfo.FaceValue.find_key(value).to_lower()]
			));
	# End for
	
	props.append({
		"name": "Special", "hint_string": "card_special_",
		"type": TYPE_NIL, "usage": PROPERTY_USAGE_GROUP,
	});
	props.append(_create_card_visual_data_property_dict("card_special_joker_red"));
	props.append(_create_card_visual_data_property_dict("card_special_joker_black"));
	
	return props;


# 
func property_can_revert(property: String) -> bool:
	return property.begins_with("card_");


# 
func property_get_revert(property: String):
	var default: CardVisualData = CardVisualData.new();
	_populate_suit_and_value_for(property, default);
	return default;


# 
func _get(property: String):
	if (property_can_revert(property)):
		return deck_card_visual_data.get(property, property_get_revert(property));
	
	if (property == "script"):
		return get_script();


# 
func _set(property: String, value) -> bool:
	if (property_can_revert(property) and value is CardVisualData):
		var data: CardVisualData = value as CardVisualData;
		_populate_suit_and_value_for(property, data);
		deck_card_visual_data[property] = data;
		return true;
	
	return false;
