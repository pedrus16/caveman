#*
#* pursue.gd
#* =============================================================================
#* Copyright (c) 2023-present Serhii Snitsaruk and the LimboAI contributors.
#*
#* Use of this source code is governed by an MIT-style
#* license that can be found in the LICENSE file or at
#* https://opensource.org/licenses/MIT.
#* =============================================================================
#*
@tool
extends BTAction
## Move towards the target until the agent is flanking it. [br]
## Returns [code]RUNNING[/code] while moving towards the target but not yet at the desired position. [br]
## Returns [code]SUCCESS[/code] when at the desired position relative to the target (flanking it). [br]
## Returns [code]FAILURE[/code] if the target is not a valid [Node2D] instance. [br]

## Blackboard variable that stores our target (expecting Node2D).
@export var target_position_var := &"pos"

## Blackboard variable that stores desired speed.
@export var speed_var: StringName = &"speed"

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Move to %s" % [LimboUtility.decorate_var(target_position_var)]


# Called each time this task is entered.
func _enter() -> void:
	var target: Vector3 = blackboard.get_var(target_position_var, null)
	agent.navigation_agent.set_target_position(target)


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	var target: Vector3 = blackboard.get_var(target_position_var, null)
	var speed: float = blackboard.get_var(speed_var, 10.0)
	
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(agent.navigation_agent.get_navigation_map()) == 0:
		return RUNNING
		
	if agent.navigation_agent.is_navigation_finished():
		agent.navigation_agent.set_velocity(Vector3.ZERO)
		agent.animation_player.stop()
		return SUCCESS
		
	var current_agent_position: Vector3 = agent.global_position
	var next_path_position: Vector3 = agent.navigation_agent.get_next_path_position()

	var direction = current_agent_position.direction_to(next_path_position)
	var velocity = direction * speed

	if agent.navigation_agent.avoidance_enabled:
		agent.navigation_agent.set_velocity(velocity)
	else:
		agent._on_navigation_agent_3d_velocity_computed(velocity)

	var angle = Vector2(-direction.z, -direction.x).angle()
	agent.mesh_instance.set_instance_shader_parameter("y_angle", angle)

	agent.animation_player.play("Walk")
	agent.animation_player.speed_scale = velocity.length() / agent.animation_reference_speed

	return RUNNING
