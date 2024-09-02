#extends Resource
#
#const SAVE_PATH = "user://high_scores.tres"
#
##var save_nodes = get_tree().get_nodes_in_group("Persist")
#
#@export var saveData = {
	#"highScores": {
		#
	#}
#}
#
#func save():
	#ResourceSaver.save(self, SAVE_PATH)
	#
	#return saveData
#
#static func load_or_create():
	#var res: SaveData
	#if FileAccess.file_exists(SAVE_PATH):
		#res = load(SAVE_PATH) as SaveData
	#else:
		#res = SaveData.new()
	#return res
