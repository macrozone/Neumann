
createRandomField = (width, height, possibility=0.05) ->
	randomCell = ->
		if Math.random() < possibility then true else false
	(randomCell() for a in [0..width-1] for b in [0..height-1])

parse = (rules) ->
	[alive, born] = rules.split "/"
	alive: (parseInt i for i in alive.split "")
	born: (parseInt i for i in born.split "")

TILES_SIZE = 256 # OPTIMAL
Router.route "GameOfLife", 
	onBeforeAction: ->
		@next()
	data: ->
		width = 768
		height = 768
		
		width: width
		height: height
		rules: "23/3"
		engine: new Engine new GameOfLife 
			startData: createRandomField width,height
			rules: parse "23/3"



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
						false: createPixel 255,0,0,0

				tileY = y
				tileX = x
				tiles[tileY][tileX] = 
					canvas: canvas
					context: context
					clear: ->
						context.clearRect 0, 0, canvas.width, canvas.height
					draw: (state, x, y, type) ->
						context.putImageData pixelMap[type][state], x-TILES_SIZE*tileX, y-TILES_SIZE*tileY
		$container.append $ "<br />"
	
	clear = ->
		console.log "clear"
		for row in tiles
			tile.clear() for tile in row
				

	draw = (state, x, y, type = "changes") ->
		tileX = x // TILES_SIZE
		tileY = y // TILES_SIZE
		
		tiles[tileY][tileX].draw state, x,y, type
	
	
	for row,y in @data.engine.data()
		for state, x in row
			draw state, x, y, "initial"

	@autorun => 
		if Template.currentData().engine.isResetted()
			Tracker.nonreactive ->
				
				for row,y in Template.currentData().engine.data()
					for state, x in row
						draw state, x, y, "initial"

	@autorun =>
		
		for change in Template.currentData().engine.changes()
			draw change.state, change.x, change.y 
		

Template.gameOfLife.events
	'click .play': (event, template) ->
		template.data.engine.play()
	'click .step': (event, template) ->
		template.data.engine.stop()
		template.data.engine.step()
	'click .reset': (event, template) ->
		template.data.engine.reset()
	'change .rules': (event, template) ->
		Template.currentData()?.engine?.automaton?.rules = parse $(event.target).val()