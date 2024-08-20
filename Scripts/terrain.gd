extends TileMapLayer

@onready var flock: Node = %Flock

class TerrainTile: 
	var name: String
	var tileSetCoord: Vector2
	var ratio: float
	var levelEnd: float #end of range of this tile in the general terrainArray
	#var typeLevelEnd: float #end of range of this tile in the type specific array (WATER, DIRT, ROCK, BRUSH)
	var type: TileType
	func _init():
		name = "Blank"
		tileSetCoord = Vector2(-1, -1)
		ratio = 0
		levelEnd = 0 
		type = TileType.OTHER

var tilePixelWidth : int = 16
var isWorldGenerating : bool = true
var worldGenerateThread : Thread
var flockCenter : Vector2 = Vector2(0,0)

#var blankTile : TerrainTile

enum TileType {WATER, DIRT, ROCK, BRUSH, OTHER}

var chunkSize :int = 512
var filledChunkArray : Array[Vector2] = []

var readyWidth := 500
var readyHeight := 500
var dirtMap := FastNoiseLite.new()
var WaterMap := FastNoiseLite.new()
var pregenAreaMultiply = 1.5

var terrainArray : Array = []
var waterArray : Array = []
var dirtArray : Array = []
var greebleArray : Array = []





func defineTerrainItems():
	var tile
	
#Water 
	tile = TerrainTile.new()
	tile.name = "water0"
	tile.ratio = .5
	tile.tileSetCoord = Vector2(0,4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water1"
	tile.ratio = .1
	tile.tileSetCoord = Vector2(1,4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water2"
	tile.ratio = .1
	tile.tileSetCoord = Vector2(2, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water3"
	tile.ratio = .10
	tile.tileSetCoord = Vector2(3, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water4"
	tile.ratio = .05
	tile.tileSetCoord = Vector2(4, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water5"
	tile.ratio = .05
	tile.tileSetCoord = Vector2(5, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water6"
	tile.ratio = .03
	tile.tileSetCoord = Vector2(6, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "water7"
	tile.ratio = .02
	tile.tileSetCoord = Vector2(7, 4)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "riverBank0"
	tile.ratio = .01
	tile.tileSetCoord = Vector2(0, 0)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "riverBank1"
	tile.ratio = .1
	tile.tileSetCoord = Vector2(1, 0)
	tile.type = TileType.WATER
	terrainArray.push_back(tile)
	waterArray.push_back(tile)
	
#DIRT
	tile = TerrainTile.new()
	tile.name = "dirt0"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(0,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt1"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(1,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt2"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(2,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt3"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(3,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt4"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(4,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt5"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(5,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt6"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(6,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "dirt7"
	tile.ratio = 1.0/8.0
	tile.tileSetCoord = Vector2(7,0)
	tile.type = TileType.DIRT
	terrainArray.push_back(tile)
	dirtArray.push_back(tile)
	
# ROAD
	tile = TerrainTile.new()
	tile.name = "road"
	tile.ratio = 0.0
	tile.tileSetCoord = Vector2(0,2)
	tile.type = TileType.OTHER
	terrainArray.push_back(tile)
	
#ROCKS
	tile = TerrainTile.new()
	tile.name = "rockD"
	tile.ratio = .02
	tile.tileSetCoord = Vector2(0, 3)
	tile.type = TileType.ROCK
	terrainArray.push_back(tile)
	greebleArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "rockL"
	tile.ratio = .03
	tile.tileSetCoord = Vector2(1, 3)
	tile.type = TileType.ROCK
	terrainArray.push_back(tile)
	greebleArray.push_back(tile)
	
# BUSH
	tile = TerrainTile.new()
	tile.name = "brushD"
	tile.ratio = .08
	tile.tileSetCoord = Vector2(0,1)
	tile.type = TileType.BRUSH
	terrainArray.push_back(tile)
	greebleArray.push_back(tile)
	
	tile = TerrainTile.new()
	tile.name = "brushL"
	tile.ratio = .12
	tile.tileSetCoord = Vector2(1,1)
	tile.type = TileType.BRUSH
	terrainArray.push_back(tile)
	greebleArray.push_back(tile)
	
	#setRangesForward(terrainArray)
	#setRangesBackward(waterArray)
	

func setRangesForward(a: Array, startPosition : int  = 0): 
# calculate end of range for each element
	var sum = startPosition 
	for item in a:
		sum += item.ratio
		item.levelEnd = sum
		
func setRangesBackward(a: Array, endPosition : int = 100): 
# calculate end of range for each element
	var sum = endPosition
	for i  in range(a.size() - 1, 0, -1):
		a[i].levelEnd = sum
		sum -= a[i].ratio
	if sum > 0:
		var blankTile = TerrainTile.new()
		blankTile.levelEnd = sum
		a.push_back(blankTile)



func setRangeFill(a:Array, minimum : float = 0, maximum : float = 1):
	
	var ratioSum : float = 0
	var sum : float = 0.0
	for item in a:
		ratioSum += item.ratio
	
#add blank to beggining of array if min greater than 0
	if minimum > 0: 
		var blankTileStart = TerrainTile.new()
		blankTileStart.levelEnd = minimum
		a.push_front(blankTileStart)
		sum = minimum
#get end markers 
	for item in a:
		sum += (item.ratio/ratioSum) * (maximum - minimum)
		item.levelEnd = sum
#add blank to end if max not 1
	if maximum < 1:
		var blankTileEnd = TerrainTile.new()
		blankTileEnd.levelEnd = 1
		a.push_back(blankTileEnd)
	
	#for item in a: 
		#print(item.name, " ", item.levelEnd)

func invertArray(a : Array):
	var inverted : Array = []
	for item in a:
		inverted.push_front(item)
	return inverted



func _ready() -> void:
	defineTerrainItems()
	randomize()
	dirtMap.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC
	dirtMap.frequency = .5
	WaterMap.noise_type = FastNoiseLite.TYPE_CELLULAR
	WaterMap.frequency = .005
	WaterMap.set_cellular_distance_function(FastNoiseLite.DISTANCE_EUCLIDEAN)
	WaterMap.set_domain_warp_enabled(true)
	WaterMap.set_domain_warp_type(FastNoiseLite.DOMAIN_WARP_SIMPLEX)
	WaterMap.set_domain_warp_amplitude(150)
	WaterMap.set_domain_warp_frequency(.014)
	waterArray = invertArray(waterArray)
	setRangeFill(waterArray, .70, 1)
	setRangeFill(dirtArray)
	
	for x in range(-2, 3):
		for y in range(-2, 3):
			draw_chunk(Vector2(x,y))
			#print("chunk drawn:", x, ",", y)
	

	

func _process(_delta: float) -> void:
	var chunkSizeQuad = sqrt(pow(chunkSize * tilePixelWidth, 2)*2) * .5
	if abs(flockCenter.distance_to(flock.getCenter())) > (chunkSizeQuad * .1) :
		flockCenter = flock.getCenter()
		var currentChunk: Vector2i = get_current_chunk_address()
		var adjEmptyChunks : Array = get_adjacent_draw_status(currentChunk)
		if adjEmptyChunks.size() > 0:
			for chunk in adjEmptyChunks:
				#print("draw chunk ", chunk)
				draw_chunk(chunk)


func get_current_chunk_address() -> Vector2i:
	var currentChunk : Vector2i = flock.getCenter() / (chunkSize * tilePixelWidth)

	return currentChunk
	
func get_adjacent_draw_status(address : Vector2i) -> Array[Vector2i]:
	var returnArray : Array[Vector2i] = []
	var offsets : Array[Vector2i] = [\
	Vector2(-2,1), Vector2(-1,1), Vector2(0,1), Vector2(1,1),\
	Vector2(-2,1), Vector2(-1,0), Vector2(0,0), Vector2(1,0),\
	Vector2(-2,-1), Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),\
	Vector2(-2,-2), Vector2(-1,-2), Vector2(0,-2), Vector2(1,-2)]
	
	for offset in offsets:
		if !is_chunk_drawn(address + offset):
			returnArray.push_back(address + offset)
	
	#print("adjacent array")
	#for obj in returnArray:
		#print(obj)
	
	return returnArray


func is_chunk_drawn(address : Vector2) -> bool :
	filledChunkArray.sort()
	var arraypos : int = filledChunkArray.bsearch(address)
	if arraypos < filledChunkArray.size() && filledChunkArray[arraypos] == address:
		return true
	else: return false
	
func draw_chunk(address : Vector2):
	filledChunkArray.push_back(address)
	var chunk = get_chunk_rect(address)
	generateMap(WaterMap, waterArray, chunk, -1, -.09)
	generateMap(dirtMap, dirtArray, chunk, -2, 2)

func get_chunk_rect(address : Vector2) -> Rect2:
	var position : Vector2 = address * chunkSize
	return Rect2(position, Vector2(chunkSize, chunkSize))

func generateMap(map : FastNoiseLite, tileArray: Array, rect: Rect2, noiseRangeMin : float = -1, noiseRangeMax : float = 1, isInvert : bool = false):
	var width : int = rect.size.x as int
	var height : int = rect.size.y as int
	var xPos : int = rect.position.x as int
	var yPos : int  = rect.position.y as int
	
	for x in range(xPos, xPos + width):
		for y in range(yPos, yPos + width):
			if !get_cell_tile_data(Vector2i(x, y)):
				var noiseVal = map.get_noise_2d(x, y)
				var color = get_color(tileArray, noiseVal, noiseRangeMin, noiseRangeMax)
				if isInvert:
					color = -color
				if color != Vector2(-1, -1):
					set_cell(Vector2i(x, y), 0, color )

func get_color(layerTiles: Array, noiseVal : float, noiseRangeMin : float = -1, noiseRangeMax : float = 1) -> Vector2:
	var noiseRange = noiseRangeMax - noiseRangeMin
	for tile in layerTiles:
		if noiseVal < (noiseRange * tile.levelEnd) + noiseRangeMin: 
			return tile.tileSetCoord 
	return Vector2(-1, -1)
	
