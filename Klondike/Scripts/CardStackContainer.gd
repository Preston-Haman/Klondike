tool
class_name CardStackContainer extends Container


# 
export(KlondikeState.CardStack) var card_stack: int;

# 
export var fan_cards: bool = true setget _set_fan_cards;

# 
export var face_down_card_offset: int = 10 setget _set_face_down_card_offset;

# 
export var card_offset: int = 42 setget _set_card_offset;

# 
export var card_size: Vector2 = Vector2(126, 180) setget _set_card_size;

# 
export var background: StyleBox = _get_default_background() setget _set_background;

# Set when the user starts dragging cards, and cleared when it ends.
var card_cluster: CardCluster;


# 
func _notification(what: int) -> void:
	if (what == NOTIFICATION_SORT_CHILDREN):
		_on_notification_sort_children();
	
	if (what == NOTIFICATION_DRAG_END and card_cluster != null):
		if (!get_viewport().gui_is_drag_successful()):
			for child_index in range(card_cluster.source_stack_index, get_child_count()):
				var child: CardVisual = get_child(child_index) as CardVisual;
				if (child != null and !child.visible):
					child.visible = true;
			# End for
		card_cluster = null;


# 
func _ready() -> void:
	_set_background(background);


# 
func _gui_input(event: InputEvent) -> void:
	if (card_stack == KlondikeState.CardStack.TALON and event is InputEventMouseButton):
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton;
		if (mouse_event.pressed):
			GameState.draw_cards();
			accept_event();


# 
func can_drop_data(_position: Vector2, data: CardCluster) -> bool:
	var off_limits_card_stacks: Array = [KlondikeState.CardStack.TALON, KlondikeState.CardStack.WASTE];
	if (data == null or card_stack == data.source_stack or card_stack in off_limits_card_stacks):
		return false;
	
	return GameState.check_move(data.source_stack, data.source_stack_index, card_stack);


# 
func drop_data(_position: Vector2, data: CardCluster) -> void:
	GameState.attempt_move(data.source_stack, data.source_stack_index, card_stack);


# 
func add_card(card: Card) -> void:
	assert(card != null);
	var card_visual: CardVisual = CardVisual.new(card, card_stack);
	
	# warning-ignore:return_value_discarded
	card_visual.connect("wants_to_drag", self, "_on_card_visual_wants_to_drag", [card_visual]);
	
	# warning-ignore:return_value_discarded
	card_visual.connect("flipped", self, "queue_sort");
	add_child(card_visual);


# 
func _on_card_visual_wants_to_drag(drag_data: CardCluster, card_visual: CardVisual) -> void:
	var card_index: int = card_visual.get_position_in_parent();
	var top_card: bool = card_index == get_child_count() - 1;
	if (!card_visual.face_down and (card_stack != KlondikeState.CardStack.WASTE or top_card)):
		var moving_cards: Array = [];
		for i in range(card_index, get_child_count()):
			var child_visual: CardVisual = get_child(i) as CardVisual;
			if (child_visual != null):
				child_visual.visible = false;
				moving_cards.append(child_visual.get_card());
		# End for
		
		# Can't type-hint this without cyclic reference nonsense.
		var preview_container = get_script().new();
		for card in moving_cards:
			preview_container.add_card(card);
		# End for
		
		card_cluster = drag_data;
		drag_data.approve_drag(card_stack, card_index, preview_container);


# 
func _on_notification_sort_children() -> void:
	var height_offset: int = 0;
	for child in get_children():
		var card_visual: CardVisual = child as CardVisual;
		if (card_visual == null or card_visual.is_queued_for_deletion() or card_visual.is_set_as_toplevel() \
		or !card_visual.visible):
			continue;
		
		fit_child_in_rect(
			card_visual,
			Rect2(Vector2(0.0, height_offset), card_visual.get_combined_minimum_size())
		);
		
		if (fan_cards):
			height_offset += face_down_card_offset if (card_visual.face_down) else card_offset;
	# End for


# 
func _get_minimum_size() -> Vector2:
	# warning-ignore:narrowing_conversion
	var height: int = card_size.y;
	
	if (fan_cards):
		for i in range(1, get_child_count()):
			var card: CardVisual = get_child(i) as CardVisual;
			if (card != null and !card.is_queued_for_deletion() and card.visible):
				height += face_down_card_offset if (card.face_down) else card_offset;
		# End for
	
	return Vector2(card_size.x, height);


# 
func _get_default_background() -> StyleBox:
	var style: StyleBoxFlat = StyleBoxFlat.new();
	style.bg_color = Color(0x8B97ADFF);
	style.draw_center = false;
	style.border_width_left = 4;
	style.border_width_top = 4;
	style.border_width_right = 4;
	style.border_width_bottom = 4;
	style.border_color = Color(0x3C3C3CFF);
	style.border_blend = true;
	style.corner_radius_top_left = 8;
	style.corner_radius_top_right = 8;
	style.corner_radius_bottom_right = 8;
	style.corner_radius_bottom_left = 8;
	style.resource_local_to_scene = true;
	return style;


# 
func _update_card_separation() -> void:
	# warning-ignore:narrowing_conversion
	var offset: int = card_offset - card_size.y if (fan_cards) else -card_size.y;
	add_constant_override("separation", offset);


# 
func _draw() -> void:
	if (background != null):
		background.draw(get_canvas_item(), Rect2(Vector2.ZERO, card_size));


# 
func _set_fan_cards(fan_cards_: bool) -> void:
	fan_cards = fan_cards_;
	queue_sort();


# 
func _set_face_down_card_offset(face_down_card_offset_: int) -> void:
	face_down_card_offset = face_down_card_offset_;
	queue_sort();


# 
func _set_card_offset(card_offset_: int) -> void:
	card_offset = card_offset_;
	queue_sort();


#
func _set_card_size(card_size_: Vector2) -> void:
	card_size = card_size_;
	queue_sort();


# 
func _set_background(background_: StyleBox) -> void:
	background = background_;
	if (background != null and !background.is_connected("changed", self, "update")):
		# warning-ignore:return_value_discarded
		background.connect("changed", self, "update");
	
	update();
