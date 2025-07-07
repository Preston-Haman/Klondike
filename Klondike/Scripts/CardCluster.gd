# The data provided to Godot's dragging API to represent a card, or set of cards, being dragged
# by the user via mouse input..
class_name CardCluster extends Reference


# 
var source_stack: int;

# 
var source_stack_index: int;

# 
var drag_approved: bool = false;

# 
var preview: Control;


# 
func approve_drag(source_stack_: int, source_stack_index_: int, preview_: Control) -> void:
	source_stack = source_stack_;
	source_stack_index = source_stack_index_;
	preview = preview_;
	drag_approved = true;
