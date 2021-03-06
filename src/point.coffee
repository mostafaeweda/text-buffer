{deprecate} = require 'grim'

# Public: Represents a point in a buffer in row/column coordinates.
#
# Every public method that takes a point also accepts a *point-compatible*
# {Array}. This means a 2-element array containing {Number}s representing the
# row and column. So the following are equivalent:
#
# ```coffee
# new Point(1, 2)
# [1, 2] # Point compatible Array
# ```
module.exports =
class Point
  ###
  Section: Construction
  ###

  # Public: Convert any point-compatible object to a {Point}.
  #
  # * `object` This can be an object that's already a {Point}, in which case it's
  #   simply returned, or an array containing two {Number}s representing the
  #   row and column.
  # * `copy` An optional boolean indicating whether to force the copying of objects
  #   that are already points.
  #
  # Returns: A {Point} based on the given object.
  @fromObject: (object, copy) ->
    if object instanceof Point
      if copy then object.copy() else object
    else
      if Array.isArray(object)
        [row, column] = object
      else
        { row, column } = object

      new Point(row, column)

  ###
  Section: Comparison
  ###

  # Public: Returns the given {Point} that is earlier in the buffer.
  #
  # * `point1` {Point}
  # * `point2` {Point}
  @min: (point1, point2) ->
    point1 = @fromObject(point1)
    point2 = @fromObject(point2)
    if point1.isLessThanOrEqual(point2)
      point1
    else
      point2

  ###
  Section: Construction
  ###

  # Public: Construct a {Point} object
  #
  # * `row` {Number} row
  # * `column` {Number} column
  constructor: (@row=0, @column=0) ->

  # Public: Returns a new {Point} with the same row and column.
  copy: ->
    new Point(@row, @column)

  # Public: Returns a new {Point} with the row and column negated.
  negate: ->
    new Point(-@row, -@column)

  ###
  Section: Operations
  ###

  # Public: Makes this point immutable and returns itself.
  #
  # Returns an immutable version of this {Point}
  freeze: ->
    Object.freeze(this)

  # Public: Build and return a new point by adding the rows and columns of
  # the given point.
  #
  # * `other` A {Point} whose row and column will be added to this point's row
  #   and column to build the returned point.
  #
  # Returns a {Point}.
  translate: (other) ->
    {row, column} = Point.fromObject(other)
    new Point(@row + row, @column + column)

  # Public: Build and return a new {Point} by traversing the rows and columns
  # specified by the given point.
  #
  # * `other` A {Point} providing the rows and columns to traverse by.
  #
  # This method differs from the direct, vector-style addition offered by
  # {::translate}. Rather than adding the rows and columns directly, it derives
  # the new point from traversing in "typewriter space". At the end of every row
  # traversed, a carriage return occurs that returns the columns to 0 before
  # continuing the traversal.
  #
  # ## Examples
  #
  # Traversing 0 rows, 2 columns:
  # `new Point(10, 5).traverse(new Point(0, 2)) # => [10, 7]`
  #
  # Traversing 2 rows, 2 columns. Note the columns reset from 0 before adding:
  # `new Point(10, 5).traverse(new Point(2, 2)) # => [12, 2]`
  #
  # Returns a {Point}.
  traverse: (other) ->
    other = Point.fromObject(other)
    row = @row + other.row
    if other.row == 0
      column = @column + other.column
    else
      column = other.column

    new Point(row, column)

  add: (other) ->
    deprecate("Use Point::traverse instead")
    @traverse(other)

  splitAt: (column) ->
    if @row == 0
      rightColumn = @column - column
    else
      rightColumn = @column

    [new Point(0, column), new Point(@row, rightColumn)]

  ###
  Section: Comparison
  ###

  # Public:
  #
  # * `other` A {Point} or point-compatible {Array}.
  #
  # Returns `-1` if this point precedes the argument.
  # Returns `0` if this point is equivalent to the argument.
  # Returns `1` if this point follows the argument.
  compare: (other) ->
    if @row > other.row
      1
    else if @row < other.row
      -1
    else
      if @column > other.column
        1
      else if @column < other.column
        -1
      else
        0

  # Public: Returns a {Boolean} indicating whether this point has the same row
  # and column as the given {Point} or point-compatible {Array}.
  #
  # * `other` A {Point} or point-compatible {Array}.
  isEqual: (other) ->
    return false unless other
    other = Point.fromObject(other)
    @row == other.row and @column == other.column

  # Public: Returns a {Boolean} indicating whether this point precedes the given
  # {Point} or point-compatible {Array}.
  #
  # * `other` A {Point} or point-compatible {Array}.
  isLessThan: (other) ->
    @compare(other) < 0

  # Public: Returns a {Boolean} indicating whether this point precedes or is
  # equal to the given {Point} or point-compatible {Array}.
  #
  # * `other` A {Point} or point-compatible {Array}.
  isLessThanOrEqual: (other) ->
    @compare(other) <= 0

  # Public: Returns a {Boolean} indicating whether this point follows the given
  # {Point} or point-compatible {Array}.
  #
  # * `other` A {Point} or point-compatible {Array}.
  isGreaterThan: (other) ->
    @compare(other) > 0

  # Public: Returns a {Boolean} indicating whether this point follows or is
  # equal to the given {Point} or point-compatible {Array}.
  #
  # * `other` A {Point} or point-compatible {Array}.
  isGreaterThanOrEqual: (other) ->
    @compare(other) >= 0

  ###
  Section: Conversion
  ###

  # Public: Returns an array of this point's row and column.
  toArray: ->
    [@row, @column]

  # Public: Returns an array of this point's row and column.
  serialize: ->
    @toArray()

  # Public: Returns a string representation of the point.
  toString: ->
    "(#{@row}, #{@column})"
