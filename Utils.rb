include Math

module Utils

  def self.create_grid()## Create board
    board = Array.new($RESOLUTION)
    for i in (0...$RESOLUTION)
      board[i] = Array.new($RESOLUTION)
      for j in (0...$RESOLUTION)
        board[i][j] = $BACKGROUND_COLOR
      end
    end
    return board
  end


  ## Write GRID to OUTFILE
  def self.write_out(file: $OUTFILE, mat: $TEMP_MAT)
    puts "Writing out to #{file}" if $DEBUGGING
    extension = file.dup #filename with any extension
    file[file.index('.')..-1] = '.ppm'
    #$GRID = create_grid()
    outfile = File.open(file, 'w')
    outfile.puts "P3 #$RESOLUTION #$RESOLUTION 255" #Header in 1 line

    #Write PPM data
    for row in $GRID
      for pixel in row
        for rgb in pixel
          outfile.print rgb
          outfile.print ' '
        end
        outfile.print '   '
      end
      outfile.puts ''
    end
    outfile.close()

    #Convert filetype
    puts %x[convert #{file} #{extension}]
    if not extension["ppm"]
      puts %x[rm #{file}] end
  end

  def self.display(tempfile: $TEMPFILE)
    write_out(file: tempfile)
    puts %x[display #{tempfile}]
    puts %x[rm #{tempfile}]
  end

  def self.parse_file(filename: $INFILE)
    file = File.new(filename, "r")
    while (line = file.gets)
      line = line.chomp #Kill trailing newline
      puts "Executing command: \"" + line + '"' if $DEBUGGING
      case line
      when "line"
        args = file.gets.chomp.split(" ")
        for i in (0...6); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4,0)
        temp.add_col([args[0], args[1], args[2], 1])
        temp.add_col([args[3], args[4], args[5], 1])
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_edge_matrix(temp)
      when "circle"
        args = file.gets.chomp.split(" ")
        for i in (0...4); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.circle(args[0], args[1], args[2], args[3], temp)
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_edge_matrix(temp)
      when "hermite"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.hermite(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], temp)
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_edge_matrix(temp)
      when "bezier"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.bezier(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], temp)
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_edge_matrix(temp)
      when "box"
        args = file.gets.chomp.split(" ")
        for i in (0...6); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.box(args[0], args[1], args[2], args[3], args[4], args[5], temp)
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_polygon_matrix(temp)
      when "sphere"
        args = file.gets.chomp.split(" ")
        for i in (0...4); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.sphere(args[0], args[1], args[2], args[3], temp)
        Draw.push_polygon_matrix(MatrixUtils.multiply($COORDSYS.peek(), temp))
      when "torus"
        args = file.gets.chomp.split(" ")
        for i in (0...5); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        temp = Matrix.new(4, 0)
        Draw.torus(args[0], args[1], args[2], args[3], args[4], temp)
        MatrixUtils.multiply($COORDSYS.peek(), temp)
        Draw.push_polygon_matrix(temp)
      when "clear"
        $GRID = create_grid()
      when "scale"
        args = file.gets.chomp.split(" ")
        for i in (0...3); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        scale = MatrixUtils.dilation(args[0], args[1], args[2])
        $COORDSYS.modify_top(scale);
      when "move"
        args = file.gets.chomp.split(" ")
        for i in (0...3); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        move = MatrixUtils.translation(args[0], args[1], args[2])
        $COORDSYS.modify_top(move);
      when "rotate"
        args = file.gets.chomp.split(" ")
        puts "With arguments: "  + args.to_s if $DEBUGGING
        rotate = MatrixUtils.rotation(args[0], args[1].to_f)
        $COORDSYS.modify_top(rotate);
      when "pop"
        $COORDSYS.pop()
      when "push"
        $COORDSYS.push()
      when "display"
        display();
      when "save"
        arg = file.gets.chomp
        write_out(file: arg)
      when "quit", "exit"
        exit 0
      else
        puts "ERROR: Unrecognized command \"" + line + '"'
      end
    end
    file.close
  end

end
