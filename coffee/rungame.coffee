CANVAS_HEIGHT = 700
CANVAS_WIDTH  = 700
SENSITIVITY = 50
CANVAS = null
CONTEXT = null

diagram = null
active_points = []

# Aux {{{
del = (arr, x) -> # no return value
	arr.splice(arr.indexOf(x), 1) # delete p

pointSort = (arr) ->
	arr.sort((p,q) -> p.i - q.i)

tempAddClass = (elm, cls, time=1000) ->
	$(elm).addClass(cls)
	removeCallback = () -> $(elm).removeClass(cls)
	setTimeout removeCallback, time


# }}}

# Geometry {{{
class Point
	constructor: (@name, @x, @y, @i) ->
		# no need to do anything, lol!
		# The @i gives a unique ordering to each tuple
	toString: () ->
		@name
		
class Diagram
	constructor: (json_array) ->
		umin = json_array["min"][0]
		umax = json_array["max"][0]
		vmin = json_array["min"][1]
		vmax = json_array["max"][1]
		width = json_array["width"]
		height = json_array["height"]
		@points = {}
		@flat_points = []
		i = 0
		for point_array in json_array["points"]
			pu = point_array[1]
			pv = point_array[2]
			px = width * (pu-umin)/(umax-umin)
			py = height * (vmax-pv)/(vmax-vmin)
			p = new Point(point_array[0], px, py, i)
			@points[point_array[0]] = p
			@flat_points.push(p)
			i += 1
		@tuples = []
		@unfound_tuples = [] # will be stringified
		for tuple in json_array["tuples"]
			sortedPointTuple = pointSort( (@points[name] for name in tuple) )
			nameTuple = (p.toString() for p in sortedPointTuple)
			@tuples.push(sortedPointTuple)
			@unfound_tuples.push(JSON.stringify(nameTuple)) # Note different data type from @tuples
		@source = json_array["source"]
		@filename = json_array["filename"]
		@mistakes = 0

dist = (p, q) ->
	Math.pow(Math.pow(p.x-q.x, 2) + Math.pow(p.y-q.y, 2), 0.5)

toImg = (filename) ->
	"diagrams/" + filename + ".png"
toJSON = (filename) ->
	"diagrams/" + filename + ".json"

loadDiagram = (filename) ->
	clearAll()
	CANVAS.css "background", "url(" + toImg(filename) + ") no-repeat"
	$.getJSON(toJSON(filename),
		(data, status, xhr) ->
			diagram = new Diagram(data)
			$("#head_title").html(diagram.source)
	).error( # chain
		(jqXhr, textStatus, error) ->
			alert textStatus + " : " + error
	)
# }}}
# Canvas art and Button UI {{{
# Low-level things
drawCircle = (p, color = "blue", r = 10) ->
	CONTEXT.beginPath()
	CONTEXT.arc p.x, p.y, r, 0, 2 * Math.PI
	CONTEXT.strokeStyle = color
	CONTEXT.stroke()
fillCircle = (p, color = "blue", r = 10) ->
	CONTEXT.beginPath()
	CONTEXT.arc p.x, p.y, r, 0, 2 * Math.PI
	CONTEXT.fillStyle = color
	CONTEXT.fill()
clearAll = () ->
	CONTEXT.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT)

# jQuery button things
enableButtonIf = (selector, bool) ->
	$(selector).prop('disabled', !bool)

# High-level things
markAllActive = (c = "blue") ->
	clearAll()
	# Mark all selected points
	for p in active_points
		fillCircle(p, color=c, r=5)
		drawCircle(p, color=c, r=30)
	$("span#active_points").html(active_points.toString())

	# Decide whether "Check", Done button enabled
	enableButtonIf("#check_button", active_points.length > 0)
	enableButtonIf("#done_button", (active_points.length == 0) &&
		(diagram.unfound_tuples.length != diagram.tuples.length))

# }}}
# Click handler {{{
toggle = (p) ->
	if not (p in active_points)
		active_points.push(p)
	else
		del(active_points, p)
	markAllActive()

onDiagramClick = (e) ->
	o = new Point("", e.pageX-this.offsetLeft, e.pageY-this.offsetTop)
		# where user clicked
	# Grab the closest point to the click
	diagram.flat_points.sort( (p,q) -> dist(o,p)-dist(o,q) )
	p = diagram.flat_points[0]
	if dist(o,p) < SENSITIVITY
		toggle p

onCheckButtonClick = (e) ->
	clone = active_points.slice(0) # I hate JS
	stringifiedActive = JSON.stringify(
		(p.toString() for p in pointSort(clone)) )
	if stringifiedActive in diagram.unfound_tuples
		# Good job, delete it
		$("#found").append($("<li>" + active_points.toString() + "</li>"))
		del(diagram.unfound_tuples, stringifiedActive)
		# Highlight green momentarily
		markAllActive("green")
		active_points = []
		setTimeout markAllActive, 400
		tempAddClass "#check_button", "button_green"
	else
		markAllActive("red")
		tempAddClass "#check_button", "button_red"
		diagram.mistakes += 1


onDoneButtonClick = (e) ->
	if diagram.unfound_tuples.length == 0
		startNextDiagram()
		tempAddClass "#done_button", "button_green"
	else
		tempAddClass "#done_button", "button_red"
		diagram.mistakes += 1
# }}}
# Top-level game management {{{
startNextDiagram = () ->
	alert("Good job")
	console.log("Next diagram")
# }}}
# Start Game {{{

startGame = () ->
	CANVAS = $("<canvas></canvas>")
	CANVAS.attr "height", CANVAS_HEIGHT
	CANVAS.attr "width",  CANVAS_WIDTH
	CANVAS.click onDiagramClick

	CONTEXT = CANVAS.get(0).getContext("2d")
	$("#site").empty()
	$("#site").append(CANVAS)
	$("#check_button").click onCheckButtonClick
	$("#check_button").prop('disabled', false)
	$("#done_button").click onDoneButtonClick
	$("#done_button").prop('disabled', false)

	loadDiagram "demo2"
# }}}

# Main function {{{
$ ->
	enableButtonIf("#check_button", false)
	enableButtonIf("#done_button", false)
	$("#start_game").click startGame

# }}}
# vim: fdm=marker
