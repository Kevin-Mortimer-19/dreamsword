extends Camera2D

@export var player: CharacterBody2D

@export_category("Collision Boxes")
@export var collision_boxes: Array[StaticBody2D]
#@export var bottom_collision: StaticBody2D
#@export var top_collision: StaticBody2D
#@export var right_collision: StaticBody2D
#@export var left_collision: StaticBody2D



func _ready() -> void:
	# Camera starting position determined by player's starting position relative to Map.
	position.x = floori(player.position.x / Map.TILE_WIDTH) * Map.TILE_WIDTH + (Map.TILE_WIDTH / 2)
	position.y = floori(player.position.y / Map.TILE_HEIGHT) * Map.TILE_HEIGHT + (Map.TILE_HEIGHT / 2)
	GlobalSignals.camera_movement_started.connect(phase_camera_collision_boxes)


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


func dephase_camera_collision_boxes():
	for box in collision_boxes:
		box.process_mode = Node.PROCESS_MODE_INHERIT


func move_camera(direction: Vector2) -> void:
	var tween = get_tree().create_tween()
	var target: Vector2 = position
	match direction:
		Vector2.UP:
			#position.y -= Map.TILE_HEIGHT
			target.y -= Map.TILE_HEIGHT
		Vector2.DOWN:
			#position.y += Map.TILE_HEIGHT
			target.y += Map.TILE_HEIGHT
		Vector2.LEFT:
			#position.x -= Map.TILE_WIDTH
			target.x -= Map.TILE_WIDTH
		Vector2.RIGHT:
			#position.x += Map.TILE_WIDTH
			target.x += Map.TILE_WIDTH
		_:
			push_error("Vector provided for function move_camera not a cardinal direction.")
	GlobalSignals.camera_movement_started.emit()
	tween.finished.connect(dephase_camera_collision_boxes)
	tween.tween_property(self, "position", target, 0.75)
