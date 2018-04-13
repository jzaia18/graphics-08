require './MatrixUtils.rb'
require './Matrix.rb'

class CStack
  # Wrapper class CStack makes it easy to work with co-ord systems in a stacky way

  def initialize()
    @data = []
    @data.push(MatrixUtils.identity(4))
  end

  def pop()
    @data.pop()
  end

  # Parser push, not stack push
      # Places a copy of the current top on the top
  def push()
    @data.push(@data[-1].copy())
  end

  def peek()
    @data.peek()
  end

  def modify_top()
    #fill me!
  end

end
