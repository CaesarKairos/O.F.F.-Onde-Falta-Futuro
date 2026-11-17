extends SceneTree

const EXTENSIONS := ["tscn", "tres", "gdshader"]
var failures: Array[String] = []
var loaded := 0


func _initialize() -> void:
	_scan("res://")
	print("VALIDATION loaded=%d failures=%d" % [loaded, failures.size()])
	for failure in failures:
		push_error(failure)
	quit(1 if failures else 0)


func _scan(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		failures.append("Cannot open directory: %s" % path)
		return

	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		var child := path.path_join(entry)
		if directory.current_is_dir():
			if entry not in [".git", ".godot", "builds"]:
				_scan(child)
		elif child.get_extension().to_lower() in EXTENSIONS:
			_check_text_dependencies(child)
			if ResourceLoader.load(child) == null:
				failures.append("Cannot load resource: %s" % child)
			else:
				loaded += 1
		entry = directory.get_next()
	directory.list_dir_end()


func _check_text_dependencies(path: String) -> void:
	if path.get_extension().to_lower() not in ["tscn", "tres"]:
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var regex := RegEx.new()
	regex.compile('path="(res://[^"]+)"')
	for match in regex.search_all(file.get_as_text()):
		var dependency := match.get_string(1)
		if not ResourceLoader.exists(dependency):
			failures.append("Missing dependency in %s: %s" % [path, dependency])
