extends Camera2D

@export var player: CharacterBody2D

@export_category("Collision Boxes")
@export var collision_boxes: Array[StaticBody2D]



func _ready() -> void:
	# Camera starting position determined by player's starting position relative to Map.
	position.x = floori(player.position.x / Map.TILE_WIDTH) * Map.TILE_WIDTH + (Map.TILE_WIDTH / 2)
	position.y = floori(player.position.y / Map.TILE_HEIGHT) * Map.TILE_HEIGHT + (Map.TILE_HEIGHT / 2)
	GlobalSignals.camera_movement_started.connect(phase_camera_collision_boxes)
	Map.camera_position = position


func _physics_process(_delta: float) -> void:
	if player != null:
		follow_player_with_camera(player.position, position)


func follow_player_with_camera(player_position: Vector2, camera_position: Vector2) -> void:
	if not Map.within_camera_bounds(player.position):
		if player_position.x > camera_position.x + (Map.TILE_WIDTH / 2):
			move_camera(Vector2.RIGHT)
		elif player_position.x < camera_position.x - (Map.TILE_WIDTH / 2):
			move_camera(Vector2.LEFT)
		if player_position.y > camera_position.y + (Map.TILE_HEIGHT / 2):
			move_camera(Vector2.DOWN)
		elif player_position.y < camera_position.y - (Map.TILE_HEIGHT / 2):
			move_camera(Vector2.UP)
	Map.camera_position = position


func phase_camera_collision_boxes():
	for box in collision_boxes:
		box.process_mode = Node.PROCESS_MODE_DISABLED


func reset_game_after_camera_move() -> void:
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.machine.change_state('Idle')
	dephase_camera_collision_boxes()


func dephase_camera_collision_boxes():
	for box in collision_boxes:
		box.process_mode = Node.PROCESS_MODE_INHERIT


func move_camera(direction: Vector2) -> void:
	var tween = get_tree().create_tween()
	var player_tween = get_tree().create_tween()
	player.process_mode = Node.PROCESS_MODE_DISABLED
	var target: Vector2 = position
	var player_target = player.position
	match direction:
		Vector2.UP:
			target.y -= Map.TILE_HEIGHT
			player_target.y -= (Map.TILE_HEIGHT/16)
		Vector2.DOWN:
			target.y += Map.TILE_HEIGHT
			player_target.y += (Map.TILE_HEIGHT/16)
		Vector2.LEFT:
			target.x -= Map.TILE_WIDTH
			player_target.x -= (Map.TILE_WIDTH/16)
		Vector2.RIGHT:
			target.x += Map.TILE_WIDTH
			player_target.x += (Map.TILE_WIDTH/16)
		_:
			push_error("Vector provided for function move_camera not a cardinal direction.")
	GlobalSignals.camera_movement_started.emit()
	tween.finished.connect(reset_game_after_camera_move)
	tween.tween_property(self, "position", target, 0.75)
	player_tween.tween_property(player, "position", player_target, 0.75)
