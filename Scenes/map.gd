extends Node2D

var map_loader: MapTileLoader
var center_lat = -23.706315158285488
var center_lon = 133.88437229170304
var zoom_level = 19
var tile_size = 256

var world_tile_offset: Vector2
var tile_sprites = {}
var tile_last_visible_time = {}
var unloaded_tiles = []
var max_cached_tiles = 9
var max_load_distance = 10  # Max distance in tiles to load around the camera
var unload_distance = 50   # Distance in tiles to start unloading tiles
var unload_delay = 10      # Delay in seconds before unloading tiles
var map_scale = 16  # The scale factor of the Map node

func _ready():
	map_loader = $MapTileLoader
	map_loader.cache_tiles = true  # Enable tile caching
	
	var center_tile = map_loader.gps_to_tile(center_lat, center_lon, zoom_level)
	world_tile_offset = Vector2(center_tile.x, center_tile.y)
	
	map_loader.tile_loaded.connect(_on_tile_loaded)
	
	_load_visible_tiles()

func _process(delta):
	_update_tile_visibility()
	_load_nearest_tile()
	_unload_distant_tiles()

func _update_tile_visibility():
	var camera = get_viewport().get_camera_2d()
	var visible_rect = get_viewport().get_visible_rect()
	visible_rect.position += camera.get_screen_center_position() - visible_rect.size / 2
	#visible_rect = visible_rect.grow(tile_size * map_scale)  # Adjust growth for scale
	
	var current_time = Time.get_ticks_msec() / 1000.0
	for tile_key in tile_sprites:
		var sprite = tile_sprites[tile_key]
		var tile_rect = sprite.get_rect()
		if visible_rect.intersects(tile_rect):  # Adjust position check for scale
			tile_last_visible_time[tile_key] = current_time

func _load_nearest_tile():
	var camera = get_viewport().get_camera_2d()
	var camera_tile = _world_to_tile(camera.get_screen_center_position())
	
	unloaded_tiles.sort_custom(func(a, b): return a.distance_squared_to(camera_tile) < b.distance_squared_to(camera_tile))
	
	while not unloaded_tiles.is_empty() and map_loader.available() > 0:
		var nearest_tile = unloaded_tiles.pop_front()
		if nearest_tile.distance_squared_to(camera_tile) <= max_load_distance * max_load_distance:
			map_loader.load_tile_by_indices(nearest_tile.x, nearest_tile.y, zoom_level, false)
		else:
			break

func _unload_distant_tiles():
	var camera = get_viewport().get_camera_2d()
	var camera_tile = _world_to_tile(camera.get_screen_center_position())
	var current_time = Time.get_ticks_msec() / 1000.0
	var to_remove = []
	
	for tile_key in tile_sprites:
		var tile_coords = tile_key.split(",")
		var tile_pos = Vector2i(int(tile_coords[0]), int(tile_coords[1]))
		if tile_pos.distance_squared_to(camera_tile) > unload_distance * unload_distance:
			if current_time - tile_last_visible_time.get(tile_key, 0) > unload_delay:
				to_remove.append(tile_key)
	
	for tile_key in to_remove:
		tile_sprites[tile_key].queue_free()
		tile_sprites.erase(tile_key)
		tile_last_visible_time.erase(tile_key)

func _load_visible_tiles():
	var camera = get_viewport().get_camera_2d()
	var view_size = get_viewport().get_visible_rect().size / map_scale  # Adjust for scale
	var camera_center = camera.get_screen_center_position() / map_scale  # Adjust for scale
	
	var tl_tile = _world_to_tile(camera_center - view_size)
	var br_tile = _world_to_tile(camera_center + view_size)
	
	for x in range(tl_tile.x - max_load_distance, br_tile.x + max_load_distance + 1):
		for y in range(tl_tile.y - max_load_distance, br_tile.y + max_load_distance + 1):
			var tile_pos = Vector2i(x, y)
			var tile_key = "%d,%d,%d" % [x, y, zoom_level]
			if not tile_key in tile_sprites and not tile_pos in unloaded_tiles:
				unloaded_tiles.append(tile_pos)

func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / (tile_size * map_scale) + world_tile_offset.x),
		floor(world_pos.y / (tile_size * map_scale) + world_tile_offset.y)
	)

func _tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		(tile_pos.x - world_tile_offset.x) * (tile_size * map_scale),
		(tile_pos.y - world_tile_offset.y) * (tile_size * map_scale)
	)

func _on_tile_loaded(status, tile):
	if status == OK:
		var image = Image.new()
		var error = image.load_png_from_buffer(tile.image) if tile.format == MapTile.Format.PNG else image.load_jpg_from_buffer(tile.image)
		
		if error != OK:
			print("Failed to load image from buffer")
			return
		
		image.resize(tile_size, tile_size, Image.INTERPOLATE_BILINEAR)
		var texture = ImageTexture.create_from_image(image)
		
		var tile_key = "%d,%d,%d" % [tile.coords.x, tile.coords.y, tile.coords.z]
		
		if tile_key in tile_sprites:
			tile_sprites[tile_key].texture = texture
		else:
			var sprite = Sprite2D.new()
			sprite.texture = texture
			sprite.position = _tile_to_world(Vector2i(tile.coords.x, tile.coords.y))
			sprite.scale = Vector2(1.0 * map_scale, 1.0 * map_scale)  # Adjust sprite scale
			sprite.material = material
			add_child(sprite)
			tile_sprites[tile_key] = sprite
		
		tile_last_visible_time[tile_key] = Time.get_ticks_msec() / 1000.0
		
		## Implement tile caching limit
		#if tile_sprites.size() > max_cached_tiles:
			#var oldest_tile = tile_last_visible_time.keys().min()
			#tile_sprites[oldest_tile].queue_free()
			#tile_sprites.erase(oldest_tile)
			#tile_last_visible_time.erase(oldest_tile)
	else:
		print("Failed to load tile: ", status)
