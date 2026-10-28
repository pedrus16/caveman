@tool
extends BTAction
## Selects a random position nearby within the specified range and stores it on the blackboard. [br]
## Returns [code]SUCCESS[/code].

## Minimum distance to the desired position.
@export var range_min: float = 0.0

## Maximum distance to the desired position.
@export var range_max: float = 50.0

## Blackboard variable that will be used to store the desired position.
@export var position_var: StringName = &"pos"


# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "SelectRandomNearbyPos  range: [%s, %s]  ➜%s" % [
		range_min, range_max,
		LimboUtility.decorate_var(position_var)]


# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer3D.map_get_iteration_id(agent.navigation_agent.get_navigation_map()) == 0:
		return RUNNING
		
	var target_distance = -1
	var count = 0
	while count < 1000 and (target_distance > range_max or target_distance <= range_min):
		agent.navigation_agent.set_target_position(NavigationServer3D.map_get_random_point(agent.navigation_agent.get_navigation_map(), agent.navigation_agent.navigation_layers, true))
		target_distance = agent.to_local(agent.navigation_agent.get_target_position()).length()
		count += 1
	blackboard.set_var(position_var, agent.navigation_agent.get_target_position())
	
	return SUCCESS
