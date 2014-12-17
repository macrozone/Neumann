
createRandomField = (width, height, possibility=0.05) ->
	randomCell = ->
		if Math.random() < possibility then true else false
	(randomCell() for a in [0..width-1] for b in [0..height-1])

TILES_SIZE = 256 # OPTIMAL
Router.route "GameOfLife", 
	data: ->
		width = 768
		height = 768
		width: width
		height: height
		engine: new Engine new GameOfLife createRandomField width,height


Template.gameOfLife.rendered = ->

	$container = @$ ".container"
	
	tiles = []
	numTiles = 
		x: (@data.width-1) // TILES_SIZE
		y: (@data.height-1) // TILES_SIZE
	for y in [0..numTiles.y]
		tiles[y] = [] unless tiles[y]? 
		for x in [0..numTiles.x] 
			do (x, y) ->
				canvas = document.createElement "canvas"
				$container.append canvas
				canvas.width = TILES_SIZE
				canvas.height = TILES_SIZE
				context = canvas.getContext "2d"
				createPixel = (r, g, b, a) ->
					pixel = context.createImageData(1, 1) # only do this once per page
					d = pixel.data # only do this once per page
					d[0] = r
					d[1] = g
					d[2] = b
					d[3] = a
					pixel
				pixelMap = 
					initial:
						true: createPixel 255,0,0,255
						false: createPixel 255,0,0,0
					changes:
						true: createPixel 255,0,0,255
						false: createPixel 255,0,0,64

				tileY = y
				tileX = x
				tiles[tileY][tileX] = 
					canvas: canvas
					context: context
					draw: (state, x, y, type) ->
						context.putImageData pixelMap[type][state], x-TILES_SIZE*tileX, y-TILES_SIZE*tileY
		$container.append $ "<br />"
	

	draw = (state, x, y, type = "changes") ->
		tileX = x // TILES_SIZE
		tileY = y // TILES_SIZE
		
		tiles[tileY][tileX].draw state, x,y, type
	
	
	for row,y in @data.engine.data()
		for state, x in row
			draw state, x, y, "initial"

	
	@autorun =>
		#context.clearRect 0, 0, canvas.width, canvas.height
		for change in @data.engine.changes()
			draw change.state, change.x, change.y 
		

Template.gameOfLife.events
	'click .play': (event, template) ->
		template.data.engine.play()
	'click .step': (event, template) ->
		template.data.engine.stop()
		template.data.engine.step()