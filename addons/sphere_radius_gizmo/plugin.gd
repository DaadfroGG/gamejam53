@tool
extends EditorPlugin

var gizmo_plugin

func _enter_tree() -> void:
	gizmo_plugin = preload("res://addons/sphere_radius_gizmo/sphere_gizmo_plugin.gd").new()
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
