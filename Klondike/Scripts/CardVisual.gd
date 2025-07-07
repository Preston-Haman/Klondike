tool
class_name CardVisual extends TextureRect


# Emitted when the user attempts to drag this card.
# 
# drag_info: CardCluster
# 	The data passed around while using Godot's drag API to represent the card(s) being dragged.
signal wants_to_drag(drag_info);


# Emitted when face_down changes.
signal flipped();


# 
export(CardInfo.Suit) var suit: int = CardInfo.Suit.NONE setget _set_suit;

# 
export(CardInfo.FaceValue) var face_value: int = CardInfo.FaceValue.EMPTY setget _set_face_value;

# 
export var face_down: bool = true setget _set_face_down;

# 
var card_stack: int = -1;

# 
var drag_data: CardCluster;


# 
func _init(card: Card = null, card_stack_: int = KlondikeState.CardStack.TALON) -> void:
	if (texture == null and (card != null or Engine.editor_hint)):
		var atlas_texture: AtlasTexture = AtlasTexture.new();
		texture = atlas_texture;
	
	if (card != null):
		suit = card.suit;
		face_value = card.face_value;
		face_down = card.face_down;
		card_stack = card_stack_;
	
	rect_min_size = Vector2(126, 180);
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;
	mouse_filter = Control.MOUSE_FILTER_PASS;


# 
func _ready() -> void:
	add_to_group("CardVisual");
	_update_atlas_texture();
	
	# warning-ignore:return_value_discarded
	DeckData.connect("deck_theme_changed", self, "_update_atlas_texture");


# 
func _gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton;
		if (mouse_event.pressed):
			_on_clicked(mouse_event.doubleclick);


# 
func get_drag_data(position: Vector2) -> CardCluster:
	var card_cluster: CardCluster = CardCluster.new();
	emit_signal("wants_to_drag", card_cluster);
	
	if (!card_cluster.drag_approved):
		return null;
	
	drag_data = card_cluster;
	
	var control_wrapper: Control = Control.new();
	control_wrapper.add_child(card_cluster.preview);
	card_cluster.preview.rect_position -= position;
	
	set_drag_preview(control_wrapper);
	return card_cluster;


# 
func get_card() -> Card:
	var card: Card = Card.new(suit, face_value);
	card.face_down = face_down;
	return card;


# 
func _on_clicked(double: bool) -> void:
	match (card_stack):
		KlondikeState.CardStack.TALON:
			# Ignore the input. We'll listen for it on the Talon stack directly.
			pass
		KlondikeState.CardStack.WASTE:
			if (double):
				GameState.attempt_blind_play(card_stack, get_position_in_parent());
				accept_event();
		_:
			if (face_down):
				if (!double):
					GameState.flip_card(card_stack, get_position_in_parent());
					accept_event();
			else:
				if (double):
					GameState.attempt_blind_play(card_stack, get_position_in_parent());
					accept_event();
	# End match


# 
func _update_atlas_texture() -> void:
	if (texture is AtlasTexture and DeckData.deck_theme != null):
		var atlas_texture: AtlasTexture = texture as AtlasTexture;
		var card: Card = Card.new(suit, face_value);
		card.face_down = face_down;
		
		var card_name: String = DeckVisualData.get_property_name_for(card);
		var card_visual_data: CardVisualData = DeckData.deck_theme.get(card_name) as CardVisualData;
		
		if (card_visual_data != null):
			atlas_texture.atlas = card_visual_data.card_texture;
			atlas_texture.region = card_visual_data.card_texture_region;
	
	property_list_changed_notify();


# 
func _set_suit(suit_: int) -> void:
	suit = suit_;
	if (suit == CardInfo.Suit.NONE):
		if (!(face_value in [CardInfo.FaceValue.BACKSIDE, CardInfo.FaceValue.EMPTY])):
			face_value = CardInfo.FaceValue.EMPTY;
	elif (suit == CardInfo.Suit.JOKER):
		if (!(face_value in [CardInfo.FaceValue.JOKER_RED, CardInfo.FaceValue.JOKER_BLACK])):
			face_value = CardInfo.FaceValue.JOKER_RED;
	else:
		# Suit is one of the four normal suits.
		var exceptions: Array = [
			CardInfo.FaceValue.BACKSIDE, CardInfo.FaceValue.EMPTY,
			CardInfo.FaceValue.JOKER_RED, CardInfo.FaceValue.JOKER_BLACK,
		];
		
		if (face_value in exceptions):
			face_value = CardInfo.FaceValue.ACE;
	
	_update_atlas_texture();


# 
func _set_face_value(face_value_: int) -> void:
	face_value = face_value_;
	
	if (face_value in [CardInfo.FaceValue.BACKSIDE, CardInfo.FaceValue.EMPTY]):
		suit = CardInfo.Suit.NONE;
	elif (face_value in [CardInfo.FaceValue.JOKER_RED, CardInfo.FaceValue.JOKER_BLACK]):
		suit = CardInfo.Suit.JOKER;
	elif (suit in [CardInfo.Suit.NONE, CardInfo.Suit.JOKER]):
		suit = CardInfo.Suit.HEARTS;
	
	_update_atlas_texture();


# 
func _set_face_down(face_down_: bool) -> void:
	var flipped: bool = face_down != face_down_;
	face_down = face_down_;
	_update_atlas_texture();
	
	if (flipped):
		emit_signal("flipped");
