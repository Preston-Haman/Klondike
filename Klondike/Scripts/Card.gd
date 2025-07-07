# Represents a playing card.
class_name Card extends Reference


# The suit associated with the card.
# 
# One of the CardInfo::Suit enum constants.
var suit: int;

# The face value of the card.
# 
# One of the CardInfo::FaceValue enum constants.
var face_value: int setget , _get_face_value;

# Whether or not this card has been placed face down.
var face_down: bool = true;

# The colour of the card, for reference.
# 
# One of the CardInfo::CardColour enum constants.
var card_colour: int;


# 
func _init(suit_: int, face_value_: int) -> void:
	suit = suit_;
	face_value = face_value_;
	
	if (face_value == CardInfo.FaceValue.JOKER_RED):
		card_colour = CardInfo.CardColour.RED;
	elif (face_value == CardInfo.FaceValue.JOKER_BLACK):
		card_colour = CardInfo.CardColour.BLACK;
	else:
		card_colour = CardInfo.get_card_color_by_suit(suit);


# Getter for face_value. Returns CardInfo::FaceValue::BACKSIDE if face_down is true.
func _get_face_value() -> int:
	return face_value if (!face_down) else CardInfo.FaceValue.BACKSIDE;


# 
func _to_string() -> String:
	return "[%s -> %s]" % [CardInfo.Suit.find_key(suit), CardInfo.FaceValue.find_key(face_value)];
