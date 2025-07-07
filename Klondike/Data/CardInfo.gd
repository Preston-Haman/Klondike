class_name CardInfo extends Reference


# The colour of a card. This is usually restricted by the card's suit.
enum CardColour {
	RED,
	BLACK,
}


# The suit of a card.
enum Suit {
	NONE = -1,
	
	# Red card
	HEARTS,
	
	# Black card
	SPADES,
	
	# Red card
	DIAMONDS,
	
	# Black card
	CLUBS,
	
	# Joker card
	JOKER,
}


# 
enum FaceValue {
	BACKSIDE = -1,
	EMPTY,
	ACE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING,
	JOKER_RED,
	JOKER_BLACK,
}


# Doesn't know how to handle CardInfo::Suit::JOKER; and, will return -1 in that case.
static func get_card_color_by_suit(suit: int) -> int:
	if (suit == Suit.JOKER):
		return -1;
	
	return CardColour.RED if (suit in [Suit.HEARTS, Suit.DIAMONDS]) else CardColour.BLACK;
