@tool
extends EditorPlugin
var format_button_scene = preload("res://addons/LintOnSave/format.tscn")
var linter_executable = "gdlint"
var formatter_executable = "gdformat"
var format_instance = format_button_scene.instantiate()


func _enter_tree():
	connect("resource_saved", _on_resource_saved)
	var editor = get_editor_interface().get_script_editor()
	var target = editor.get_child(0).get_child(0).get_child(2)
	target.add_sibling(format_instance)
	format_instance.connect("pressed", on_format_pressed)


func _exit_tree():
	var editor_settings := get_editor_interface().get_editor_settings()
	var editor = get_editor_interface().get_script_editor()
	var target = editor.get_child(0).get_child(0)

	disconnect("resource_saved", _on_resource_saved)
	format_instance.disconnect("pressed", on_format_pressed)
	target.remove_child(format_instance)
	format_instance.queue_free()


func on_format_pressed():
	var interface = get_editor_interface() as EditorInterface
	var editor = interface.get_script_editor()
	var file_popup = editor.get_child(0).get_child(0).get_child(0).get_popup() as PopupMenu
	var script = editor.get_current_script()
	if script == null:
		return 
	var resource_path = script.resource_path
	if resource_path.get_extension().to_lower() == "gd":
		run(formatter_executable, ProjectSettings.globalize_path(resource_path))
		file_popup.emit_signal("id_pressed", 10)
		interface.edit_script(script)


func _on_resource_saved(resource: Resource):
	if resource.resource_path.get_extension().to_lower() == "gd":
		run(linter_executable, ProjectSettings.globalize_path(resource.resource_path))


func run(executable: String, file_path: String):
	var output = []
	OS.execute(executable, [file_path], output, true)
	for line in output:
		print(line)
