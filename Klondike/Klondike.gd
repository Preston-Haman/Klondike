extends CanvasLayer


# 
onready var talon: CardStackContainer = $"%Talon" as CardStackContainer;

# 
onready var waste: WasteContainer = $"%Waste" as WasteContainer;

# Array<CardStackContainer>
onready var foundations: Array = [
	$"%Foundation-1", $"%Foundation-2", $"%Foundation-3", $"%Foundation-4"
];

# Array<CardStackContainer>
onready var tableau: Array = [
	$"%CardStack-1", $"%CardStack-2", $"%CardStack-3", $"%CardStack-4",
	$"%CardStack-5", $"%CardStack-6", $"%CardStack-7",
];

# 
onready var btn_about: Button = $"%BtnAbout" as Button;

# 
onready var btn_credits: Button = $"%BtnCredits" as Button;


# 
func _ready() -> void:
	# warning-ignore:return_value_discarded
	btn_about.connect("toggled", self, "_on_btn_about_toggled");
	
	# warning-ignore:return_value_discarded
	btn_credits.connect("toggled", self, "_on_btn_credits_toggled");
	
	var btn_reset: Button = $"%BtnReset" as Button;
	# warning-ignore:return_value_discarded
	btn_reset.connect("pressed", self, "_on_btn_reset_pressed");
	
	# warning-ignore:return_value_discarded
	GameState.connect("changed", self, "_on_game_state_changed");
	_on_game_state_changed();


# 
func _on_btn_about_toggled(pressed: bool, internal: bool = false) -> void:
	if (btn_credits.pressed and !internal):
		btn_credits.set_pressed_no_signal(false);
		_on_btn_credits_toggled(false, true);
	
	var lbl_about: Label = $"%LblAbout" as Label;
	lbl_about.visible = pressed;


# 
func _on_btn_credits_toggled(pressed: bool, internal: bool = false) -> void:
	if (btn_about.pressed and !internal):
		btn_about.set_pressed_no_signal(false);
		_on_btn_about_toggled(false, true);
	
	var lbl_credits: Label = $"%LblCredits" as Label;
	lbl_credits.visible = pressed;


# 
func _on_btn_reset_pressed() -> void:
	GameState.deal_game();


# 
func _on_game_state_changed() -> void:
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "CardVisual", "queue_free");
	
	for card in GameState.card_stacks[KlondikeState.CardStack.TALON]:
		talon.add_card(card);
	# End for
	
	for card in GameState.card_stacks[KlondikeState.CardStack.WASTE]:
		waste.add_card(card);
	# End for
	
	for foundation_index in range(KlondikeState.CardStack.FOUNDATION_ONE, KlondikeState.CardStack.FOUNDATION_FOUR + 1):
		var cards: Array = GameState.card_stacks[foundation_index];
		var card_stack: CardStackContainer = \
			foundations[foundation_index - KlondikeState.CardStack.FOUNDATION_ONE] as CardStackContainer;
		for card in cards:
			card_stack.add_card(card);
		# End for
	# End for
	
	for tableau_index in range(KlondikeState.CardStack.TABLEAU_ONE, KlondikeState.CardStack.TABLEAU_SEVEN + 1):
		var cards: Array = GameState.card_stacks[tableau_index];
		var card_stack: CardStackContainer = \
			tableau[tableau_index - KlondikeState.CardStack.TABLEAU_ONE] as CardStackContainer;
		for card in cards:
			card_stack.add_card(card);
		# End for
	# End for
