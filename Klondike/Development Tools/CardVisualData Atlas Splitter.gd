tool
extends Node


# 
export var deck_atlas: Resource;

# 
export var atlas_texture: Texture setget _set_atlas_texture;


# 
func _set_atlas_texture(atlas_texture_: Texture) -> void:
	atlas_texture = atlas_texture_;
	
	if (atlas_texture == null):
		deck_atlas = null;
		property_list_changed_notify();
		return;
	
	# Split the atlas out...
	deck_atlas = DeckVisualData.new();
	
	# The atlas is 512x512 with 4px padding on the sides of the image, and 4px between each row
	# of card textures. Each card is 42x60px; with 0px of space between each card in the same row.
	# The card rows are:
	# 	Four rows in order, 2 -> K for HEARTS, DIAMONDS, CLUBS, SPADES
	# 	Aces (same suit order), Joker Red, Joker Black, Backside, Empty.
	var outer_padding: int = 4;
	var card_size: Vector2 = Vector2(42, 60);
	var suit_rows: Array = [CardInfo.Suit.HEARTS, CardInfo.Suit.DIAMONDS, CardInfo.Suit.CLUBS, CardInfo.Suit.SPADES];
	for row_count in suit_rows.size():
		var offset: Vector2 = Vector2(outer_padding, (outer_padding * (row_count + 1)) + (row_count * 60));
		for card_face_value in range(CardInfo.FaceValue.TWO, CardInfo.FaceValue.KING + 1):
			var card: Card = Card.new(suit_rows[row_count], card_face_value);
			card.face_down = false;
			var property_name: String = DeckVisualData.get_property_name_for(card);
			
			var card_visual_data: CardVisualData = CardVisualData.new();
			card_visual_data.card_texture = atlas_texture;
			card_visual_data.card_texture_region = Rect2(offset, card_size);
			card_visual_data.suit = card.suit;
			card_visual_data.value = card.face_value;
			
			deck_atlas.set(property_name, card_visual_data);
			
			offset.x += card_size.x;
		# End for
	# End for
	
	var remaining_cards: Array = [
		Card.new(CardInfo.Suit.HEARTS, CardInfo.FaceValue.ACE),
		Card.new(CardInfo.Suit.DIAMONDS, CardInfo.FaceValue.ACE),
		Card.new(CardInfo.Suit.CLUBS, CardInfo.FaceValue.ACE),
		Card.new(CardInfo.Suit.SPADES, CardInfo.FaceValue.ACE),
		Card.new(CardInfo.Suit.NONE, CardInfo.FaceValue.JOKER_RED),
		Card.new(CardInfo.Suit.NONE, CardInfo.FaceValue.JOKER_BLACK),
		Card.new(CardInfo.Suit.NONE, CardInfo.FaceValue.BACKSIDE),
		Card.new(CardInfo.Suit.NONE, CardInfo.FaceValue.EMPTY),
	];
	
	var offset: Vector2 = Vector2(outer_padding, (outer_padding * 5) + (outer_padding * 60));
	for card_count in remaining_cards.size():
		var card: Card = remaining_cards[card_count] as Card;
		card.face_down = false;
		
		var property_name: String = DeckVisualData.get_property_name_for(card);
			
		var card_visual_data: CardVisualData = CardVisualData.new();
		card_visual_data.card_texture = atlas_texture;
		card_visual_data.card_texture_region = Rect2(offset, card_size);
		card_visual_data.suit = card.suit;
		card_visual_data.value = card.face_value;
		
		deck_atlas.set(property_name, card_visual_data);
		
		offset.x += card_size.x;
	# End for
	
	property_list_changed_notify();
