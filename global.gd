extends Node

@onready var ui_feed: Label = get_tree().get_root().get_node("world/canvas_layer/ui/feed")

func feed_msg(string):
	print(string)
	ui_feed.text += ("\n" + string)
