
clone = (field) ->
	copy = []
	for row, y in field
		if not copy[y]? then copy[y] = []
		for state, x in row
			copy[y][x] = state
	copy

@GameOfLife = class
	
	constructor: ({@startData, @rules}) ->

		@reset()

	reset: ->
		@data = clone @startData
		@next = clone @startData

	getData: -> @data


	step: ->
		changes = []
		for row, y in @data

			for state, x in row
				@next[y][x] = @isAlive state, x, y


		# copy array back in field
		for row, y in @next
			for state, x in row

				if @data[y][x] isnt state 
					changes.push x:x, y:y, state: state
				@data[y][x] = state

		return changes

	isAlive: (wasAlive, x,y) ->
		neighbors = @countNeighbors x, y
		if wasAlive
			for rule in @rules.alive
				return yes if neighbors is rule
		else
			for rule in @rules.born
				return yes if neighbors is rule
		no
		# slower?:
		#if wasAlive and neighbors in @rules.alive then yes
		#else if not wasAlive and neighbors in @rules.born then yes
		#else no

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

