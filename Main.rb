require './CStack.rb'
require './Draw.rb'
require './Matrix.rb'
require './MatrixUtils.rb'
require './Utils.rb'

include Math

##TAU!!!!
$TAU = PI*2

# Changeable
$RESOLUTION = 500 # All images are squares
$DEBUGGING = false
$BACKGROUND_COLOR = [100, 100, 100] # [r, g, b]
$DRAW_COLOR = [255, 255, 90] # [r, g, b]
$INFILE = "script"
$OUTFILE = "image.ppm"
$TEMPFILE = "temmmmp.ppm" # Used as temp storage for displaying
$dt = 0.1 # The amount that the parametric t is incremented by on each loop

# Static
$GRID = Utils.create_grid()
$COORDSYS = CStack.new()
$RC = $DRAW_COLOR[0] # Red component
$GC = $DRAW_COLOR[1]
$BC = $DRAW_COLOR[2]

##=================== MAIN ==========================
### Take in script file

if ARGV[0]
  $INFILE = ARGV[0]
end

Utils.parse_file()
