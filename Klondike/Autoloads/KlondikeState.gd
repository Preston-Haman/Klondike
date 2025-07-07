# Currently autoloaded as GameState
class_name KlondikeState extends Node


# Emitted when the state of the game changes.
signal changed();


# The various places that cards can be located.
enum CardStack {
	# The remainder of the deck.
	TALON,
	
	# Unplayed cards that have been pulled from the Talon.
	WASTE,
	
	# The location cards are placed while sorting them by suit, from left to right.
	FOUNDATION_ONE,
	FOUNDATION_TWO,
	FOUNDATION_THREE,
	FOUNDATION_FOUR,
	
	# The main play area, from left to right.
	TABLEAU_ONE,
	TABLEAU_TWO,
	TABLEAU_THREE,
	TABLEAU_FOUR,
	TABLEAU_FIVE,
	TABLEAU_SIX,
	TABLEAU_SEVEN,
}


# 
var card_stacks: Dictionary = {};


# 
func _init() -> void:
	for stack in CardStack.keys():
		card_stacks[CardStack[stack]] = [];
	# End for


# 
func _ready() -> void:
	randomize();
	deal_game();


# 
func deal_game() -> void:
	for stack in card_stacks.keys():
		card_stacks[stack].clear();
	# End for
	
	var deck: Array = _get_shuffled_deck();
	
	# Time to deal the game out.
	var deck_index: int = 0;
	for stack in range(CardStack.TABLEAU_ONE, CardStack.TABLEAU_SEVEN + 1):
		var card: Card = deck[deck_index] as Card;
		deck_index += 1;
		
		card.face_down = false;
		card_stacks[stack].append(card);
		
		for face_down_stack in range(stack + 1, CardStack.TABLEAU_SEVEN + 1):
			card = deck[deck_index] as Card;
			deck_index += 1;
			
			card_stacks[face_down_stack].append(card);
		# End for
	# End for
	
	card_stacks[CardStack.TALON].append_array(deck.slice(deck_index, deck.size() - 1));
	
	# Inverting here so we can pull off the back-end later.
	card_stacks[CardStack.TALON].invert();
	emit_signal("changed");


# 
func draw_cards(amount: int = 3) -> void:
	var changed: bool = false;
	
	if (card_stacks[CardStack.TALON].empty()):
		# If it's already empty, then we want to recycle from the waste stack.
		var waste_stack: Array = card_stacks[CardStack.WASTE] as Array;
		changed = !waste_stack.empty();
		card_stacks[CardStack.TALON].append_array(waste_stack);
		card_stacks[CardStack.TALON].invert();
		
		for card in card_stacks[CardStack.TALON]:
			card.face_down = true;
		# End for
		
		waste_stack.clear();
	else:
		while (amount > 0 and !card_stacks[CardStack.TALON].empty()):
			var card: Card = card_stacks[CardStack.TALON].pop_back() as Card;
			card.face_down = false;
			card_stacks[CardStack.WASTE].append(card);
			changed = true;
			amount -= 1;
		# End while
	
	if (changed):
		emit_signal("changed");


# 
func flip_card(card_stack: int, card_index: int) -> void:
	assert(card_stacks.has(card_stack) and card_stacks[card_stack].size() > card_index);
	var card: Card = card_stacks[card_stack][card_index] as Card;
	
	if (card.face_down and card_stacks[card_stack].back() == card):
		# Can only flip face-down cards that are on the top of their stack.
		card.face_down = false;
		emit_signal("changed");


# 
func check_move(card_stack: int, card_index: int, to_stack: int) -> bool:
	if (card_stack == to_stack):
		return false;
	
	assert(card_stacks.has(card_stack) and card_stacks[card_stack].size() > card_index);
	assert(card_stacks.has(to_stack));
	var card: Card = card_stacks[card_stack][card_index] as Card;
	var to_stack_array: Array = card_stacks[to_stack] as Array;
	
	var foundation_set: Array = range(CardStack.FOUNDATION_ONE, CardStack.FOUNDATION_FOUR + 1);
	var tableau_set: Array = range(CardStack.TABLEAU_ONE, CardStack.TABLEAU_SEVEN + 1);
	
	if (to_stack_array.empty()):
		if (to_stack in foundation_set):
			return card.face_value == CardInfo.FaceValue.ACE;
		
		if (to_stack in tableau_set):
			return card.face_value == CardInfo.FaceValue.KING;
		
		return false;
	
	var top_card: Card = to_stack_array.back() as Card;
	if (top_card.face_down):
		return false;
	
	if (to_stack in foundation_set):
		return card.suit == top_card.suit and card.face_value == top_card.face_value + 1;
	
	if (to_stack in tableau_set):
		return card.card_colour != top_card.card_colour and card.face_value == top_card.face_value - 1;
	
	return false;


# 
func attempt_blind_play(card_stack: int, card_index: int) -> void:
	if (_attempt_blind_play(card_stack, card_index)):
		emit_signal("changed");


# 
func attempt_move(card_stack: int, card_index: int, to_stack: int) -> void:
	if (_attempt_move(card_stack, card_index, to_stack)):
		emit_signal("changed");


# 
func _attempt_blind_play(card_stack: int, card_index: int) -> bool:
	var foundation_set: Array = range(CardStack.FOUNDATION_ONE, CardStack.FOUNDATION_FOUR + 1);
	if (card_stack in foundation_set):
		# The best move we would guess is to put it right back into the foundation.
		return false;
	
	assert(card_stacks.has(card_stack) and card_stacks[card_stack].size() > card_index);
	var card: Card = card_stacks[card_stack][card_index] as Card;
	
	if (card.face_down):
		# Can't play a face_down card.
		return false;
	
	# If it's an Ace, then we know we'll have room for it; and, we have a preference for which
	# foundation to place it in.
	if (card.face_value == CardInfo.FaceValue.ACE):
		var preferred_foundation: int = CardStack.FOUNDATION_ONE + card.suit;
		foundation_set.erase(preferred_foundation);
		foundation_set.push_front(preferred_foundation);
	
	# If it's not an Ace, then we don't have a preference for where to put it in the foundations;
	# but, if we can move it into a foundation, then let's go for that.
	for foundation in foundation_set:
		if (_attempt_move(card_stack, card_index, foundation)):
			return true;
	# End for
	
	# We know that it's not an Ace at this point. This assertion just makes that explicit.
	assert(card.face_value != CardInfo.FaceValue.ACE);
	
	var tableau_set: Array = range(CardStack.TABLEAU_ONE, CardStack.TABLEAU_SEVEN + 1);
	
	if (card_stack == CardStack.WASTE and card_stacks[card_stack].back() == card):
		# The card is at the top of the waste stack.
		# We can try to move it into the tableau.
		for tableau in tableau_set:
			if (_attempt_move(card_stack, card_index, tableau)):
				return true;
		# End for
	
	if (card_stack in tableau_set):
		# The card is in the tableau, already. We don't really know a good way to move things
		# in this context; but, we can still do basic moves like placing King cards into empty
		# slots, or revealing face-down cards or empty slots.
		if (card.face_value == CardInfo.FaceValue.KING and card_index > 0):
			for tableau in tableau_set:
				if (card_stacks[tableau].empty() and _attempt_move(card_stack, card_index, tableau)):
					return true;
			# End for
		
		if (card_index == 0 or card_stacks[card_stack][card_index - 1].face_down):
			# There either isn't a card beneath the one we want to move, or it's face-down.
			# Doesn't matter where we put it. If we can reveal the empty space, or a new card,
			# then we want to!
			for tableau in tableau_set:
				if (_attempt_move(card_stack, card_index, tableau)):
					return true;
			# End for
	
	return false;


# 
func _attempt_move(card_stack: int, card_index: int, to_stack: int) -> bool:
	assert(card_stacks.has(to_stack));
	if (to_stack in [CardStack.TALON, CardStack.WASTE]):
		# Can't move a card into either of these.
		return false;
	
	assert(card_stacks.has(card_stack) and card_stacks[card_stack].size() > card_index);
	var card: Card = card_stacks[card_stack][card_index] as Card;
	var to_stack_array: Array = card_stacks[to_stack] as Array;
	
	var foundation_set: Array = range(CardStack.FOUNDATION_ONE, CardStack.FOUNDATION_FOUR + 1);
	if (to_stack in foundation_set):
		# If we try to move multiple cards to the foundation, we'll fail.
		if (card_stacks[card_stack].back() != card):
			return false;
		
		# We're trying to move into a foundation, and we're only moving ONE card.
		if (to_stack_array.empty() and card.face_value == CardInfo.FaceValue.ACE):
			card_stacks[card_stack].remove(card_index);
			card_stacks[to_stack].append(card);
			return true;
		
		if (to_stack_array.empty()):
			return false;
		
		var top_foundation_card: Card = to_stack_array.back() as Card;
		if (top_foundation_card.suit == card.suit and top_foundation_card.face_value == card.face_value - 1):
			card_stacks[card_stack].remove(card_index);
			card_stacks[to_stack].append(card);
			return true;
		
		return false;
	
	# If we're here, then we're moving to one of the tableau stacks.
	var moving_cards: Array = card_stacks[card_stack].slice(card_index, card_stacks[card_stack].size() - 1);
	if (to_stack_array.empty()):
		if (card.face_value == CardInfo.FaceValue.KING):
			# King -> empty tableau stack
			card_stacks[card_stack].resize(card_index);
			to_stack_array.append_array(moving_cards);
			return true;
		
		return false;
	
	# If we made it here, then we know it's moving to one of the tableau stacks which is not empty.
	# We can only move to such a stack if our card's face_value is one less than the top card,
	# which must be face-up, and we're the alternate card colour.
	var top_card: Card = to_stack_array.back();
	if (top_card.face_down):
		# Putting this here to avoid having to wrap the next check.
		return false;
	
	if (top_card.face_value == card.face_value + 1 and top_card.card_colour != card.card_colour):
		# We only have two card colours; so, this check should be fine.
		card_stacks[card_stack].resize(card_index);
		to_stack_array.append_array(moving_cards);
		return true;
	
	return false;


# 
func _get_shuffled_deck() -> Array:
	var deck: Array = [];
	for suit in range(CardInfo.Suit.HEARTS, CardInfo.Suit.CLUBS + 1):
		for face_value in range(CardInfo.FaceValue.ACE, CardInfo.FaceValue.KING + 1):
			deck.append(Card.new(suit, face_value));
		# End for
	# End for
	
	deck.shuffle();
	
	# Shuffle again in the traditional way, too. I don't know if this will be an actual left/right
	# handed shuffle; but, it doesn't matter.
	for left_handed_shuffle in [true, true]:
		# warning-ignore:integer_division
		var top_deck: Array = deck.slice(0, (deck.size() / 2) - 1);
		# warning-ignore:integer_division
		var bottom_deck: Array = deck.slice(deck.size() / 2, deck.size() - 1);
		deck.clear();
		assert(top_deck.size() == bottom_deck.size());
		
		for card_index in range(top_deck.size() -1, -1, -1):
			var left_deck: Array = top_deck;
			var right_deck: Array = bottom_deck;
			
			if (left_handed_shuffle):
				deck.append(left_deck[card_index]);
				deck.append(right_deck[card_index])
			else:
				deck.append(right_deck[card_index])
				deck.append(left_deck[card_index]);
		# End for
		
		# Inverting because we iterated backwards above.
		deck.invert();
	# End for
	
	return deck;
