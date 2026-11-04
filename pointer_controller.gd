class_name PointerController
extends Camera3D

const RAY_LENGTH = 1000.0

@export var agents: Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if not result:
		return
		
	for agent in agents:
		agent.mouse_position = result.position
	DebugDraw3D.draw_box(result.position, Quaternion.IDENTITY, Vector3(1, 1, 1), Color(0, 1, 0))
