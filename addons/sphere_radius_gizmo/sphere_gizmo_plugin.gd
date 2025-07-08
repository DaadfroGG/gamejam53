@tool
extends EditorNode3DGizmoPlugin

const Target := preload("res://addons/sphere_radius_gizmo/SphereNode.gd")
const MyTexture := preload("res://1422649-200.png") # <-- Mettez le bon chemin ici

func _get_gizmo_name() -> String:
	return "TexturedQuad"

func _init() -> void:
	# Crée un matériau simple juste pour enregistrer "main"
	create_material("main", Color(1, 1, 1, 1)) 
	create_handle_material("handle")

func _has_gizmo(node: Node3D) -> bool:
	return node is Target

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	var node := gizmo.get_node_3d() as Target
	if node == null:
		return

	# Création du quad
	var mesh := QuadMesh.new()
	mesh.size = Vector2(node.radius * 2, node.radius * 2)

	# Création du matériau avec texture
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = MyTexture
	mat.emission_texture = MyTexture
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED


	# Ajout du quad avec la texture
	gizmo.add_mesh(mesh, mat)

	# Ajout du handle
	var handles := PackedVector3Array([Vector3(node.radius, 0, 0)])
	gizmo.add_handles(handles, get_material("handle", gizmo), [])
