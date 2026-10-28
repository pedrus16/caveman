extends Node3D

var movement_speed: float = 4.8
var movement_target_position: Vector3 = Vector3(0.0, 0.0, 0.0)

var animation_reference_speed: float = 2.4

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var idle_timer: Timer = $IdleTimer

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var default_navigation_map_rid: RID = get_world_3d().get_navigation_map()

var physics_delta: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.25
	navigation_agent.target_desired_distance = 0.25

	# Make sure to not await during _ready.
	actor_setup.call_deferred()
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	## Now that the navigation map is no longer empty, set the movement target.
	#set_random_movement_target()
	
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	
func set_random_movement_target():
	movement_target_position = NavigationServer3D.map_get_random_point(default_navigation_map_rid, navigation_agent.navigation_layers, true)
	set_movement_target(movement_target_position)

func _physics_process(delta):
	physics_delta = delta
	
	## Do not query when the map has never synchronized and is empty.
	#if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		#return
	#if navigation_agent.is_navigation_finished():
		#navigation_agent.set_velocity(Vector3.ZERO)
		#animation_player.stop()
		#return
	#
	#### Set a random target position if the current one is zero 
	##if movement_target_position.is_zero_approx():
		##set_random_movement_target()
#
	#var current_agent_position: Vector3 = global_position
	#var next_path_position: Vector3 = navigation_agent.get_next_path_position()
#
	#var direction = current_agent_position.direction_to(next_path_position)
	#var velocity = direction * movement_speed
#
	#if navigation_agent.avoidance_enabled:
		#navigation_agent.set_velocity(velocity)
	#else:
		#_on_navigation_agent_3d_velocity_computed(velocity)
#
	#var angle = Vector2(-direction.z, -direction.x).angle()
	#mesh_instance.set_instance_shader_parameter("y_angle", angle)
#
	#animation_player.speed_scale = velocity.length() / animation_reference_speed


func _on_navigation_agent_3d_navigation_finished() -> void:
	pass
	#idle_timer.start()
	#await idle_timer.timeout
	#animation_player.play("Walk")
	#set_random_movement_target()


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	global_position = global_position.move_toward(global_position + safe_velocity, physics_delta * movement_speed)
