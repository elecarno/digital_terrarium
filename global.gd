extends Node

@onready var ui_feed: Label = get_tree().get_root().get_node("world/canvas_layer/ui/feed")

func feed_msg(string):
	print(string)
	if ui_feed.get_line_count() == 10:
		ui_feed.text = remove_top_line(ui_feed.text)
	ui_feed.text += ("\n" + string)

func remove_top_line(original_string: String) -> String:
	var lines = original_string.split("\n")
	if lines.size() > 0:
		lines.remove_at(0)
	return "\n".join(lines)
