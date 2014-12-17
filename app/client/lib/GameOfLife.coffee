
clone = (field) ->
	copy = []
	for row, y in field
		if not copy[y]? then copy[y] = []
		for state, x in row
			copy[y][x] = state
	copy

@GameOfLife = class
	
	constructor: (@startData) ->
		@reset()

	reset: ->
		@data = clone @startData
		@next = clone @startData

	getData: -> @data


	step: ->
		changes = []
		for row, y in @data

			if not @next[y]? then @next[y] = []
			for state, x in row
				@next[y][x] = @isStillAlive state, x, y


		# copy array back in field
		for row, y in @next
			for state, x in row

				if @data[y][x] isnt state 
					changes.push x:x, y:y, state: state
				@data[y][x] = state

		return changes

	isStillAlive: (wasAlive, x,y) ->
		neighbors = @countNeighbors x, y
		return true if !wasAlive and neighbors == 3
		return false if wasAlive and neighbors < 2
		return true if wasAlive and 2 <= neighbors <= 3
		return false

	countNeighbors: (x,y) ->
		neighbors = 0

		neighbors++ if @data[y-1]?[x-1]

		neighbors++ if @data[y]?[x-1]
		neighbors++ if @data[y+1]?[x-1]

		neighbors++ if @data[y-1]?[x]
		neighbors++ if @data[y+1]?[x]

		neighbors++ if @data[y-1]?[x+1]
		neighbors++ if @data[y]?[x+1]
		neighbors++ if @data[y+1]?[x+1]
		neighbors

