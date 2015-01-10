
clone = (field) ->
	copy = []
	for row, y in field
		if not copy[y]? then copy[y] = []
		if row?
			for state, x in row
				copy[y][x] = state
	copy

@GameOfLife = class
	
	constructor: ({@rules}) ->
		@setData []

	getData: -> @data

	changeData: (change) ->
		{x,y,state} = change
		@data[y] = [] unless @data[y]?
		@data[y][x] = state
		@width = Math.max @width, x+1
		@height = Math.max @height, y+1

	setData: (@data) ->
		changes = []
		@next = []
		@width = 0
		@height = 0
		for row, y in @data
			@height = Math.max @height, y
			if row?
				for state, x in row
					@width = Math.max @width, x
					changes.push {x,y,state}
		changes

	step: ->
		changes = []


		for y in [0..@height]

			@next[y] = [] unless @next[y]?

			for x in [0..@width]
				state = @data[y]?[x]
				@next[y][x] = @isAlive state, x, y
				if @next[y][x] #adjust space
					@width = Math.max @width, x+1
					@height = Math.max @height, y+1

		# copy array back in field
		for row, y in @next
			for state, x in row
				@data[y] = [] unless @data[y]?
				
				if @data[y][x] isnt state 
					changes.push {x,y,state}
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

