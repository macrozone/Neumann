



@Engine = class
	
	constructor: (@automaton) -> 
		@drawInterval = 0.1
		@drawDelay = 0
		
		
		@automatonDep = new Tracker.Dependency
		@stateDep = new Tracker.Dependency
		@reset()

	data: ->
		@automatonDep.depend()
		@automaton.getData()

	setData: (data) ->
		@_changes = @automaton.setData data
		@automatonDep.changed()
		Tracker.flush()

	changeData: (change) ->
		@automaton.changeData change
		@_changes = [change]
		@automatonDep.changed()
		Tracker.flush()

	changes: ->
		@automatonDep.depend()
		@_changes

	counter: ->
		@automatonDep.depend()
		@_counter
	

	isRunning: ->
		@stateDep?.depend()
		@running

	isResetted: ->
		@stateDep?.depend()
		@resetted


	play: ->
		@running = !@running

		@stateDep.changed()
		turn = =>
			if @running
				@step() 

				if @drawDelay? and @drawDelay > 0
					Meteor.setTimeout turn, @drawDelay
				else
					Meteor.defer turn
		Meteor.defer turn

	stop: ->
		@running = false
		@stateDep.changed()

	reset: ->
		@_changes = []
		@_counter = 0
		@automaton.setData []

		@resetted = true
		@stateDep.changed()
		#propagate initial scope
		@automatonDep.changed()

	step: ->
		@resetted = false
		@_changes = @automaton.step()
		@_counter++
		# propagate change, this will redraw all plots
		@automatonDep.changed()
		Tracker.flush() # if using changes, flush guarantees the drawing




 