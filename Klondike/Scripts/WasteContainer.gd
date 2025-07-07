tool
class_name WasteContainer extends CardStackContainer


# 
func _on_notification_sort_children() -> void:
	var width_offset: int = 0;
	for child in get_children():
		var card_visual: CardVisual = child as CardVisual;
		if (card_visual == null or card_visual.is_queued_for_deletion() or card_visual.is_set_as_toplevel()):
			continue;
		
		fit_child_in_rect(
			card_visual,
			Rect2(Vector2(width_offset, 0.0), card_visual.get_combined_minimum_size())
		);
		
		if (fan_cards):
			width_offset += card_offset;
			width_offset %= card_offset * 3;
	# End for


# 
func _get_minimum_size() -> Vector2:
	return Vector2(card_size.x + (2 * card_offset), card_size.y);
