extends Node2D

const TILE_WIDTH: int = 256
const TILE_HEIGHT: int = 144

var camera_position: Vector2


func within_camera_bounds(point: Vector2) -> bool:
	if (point.x > camera_position.x + (TILE_WIDTH / 2)
		or point.x < camera_position.x - (Map.TILE_WIDTH / 2)
		or point.y > camera_position.y + (Map.TILE_HEIGHT / 2)
		or point.y < camera_position.y - (Map.TILE_HEIGHT / 2)):
		return false
	else:
		return true
