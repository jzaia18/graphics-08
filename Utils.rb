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
  def self.write_out(file: $OUTFILE, polymat: $POLY_MAT, edgemat: $EDGE_MAT)
    puts "Writing out to #{file}" if $DEBUGGING
    extension = file.dup #filename with any extension
    file[file.index('.')..-1] = '.ppm'
    $GRID = create_grid()
    Draw.push_polygon_matrix(polymat: polymat)
    Draw.push_edge_matrix(edgemat: edgemat)
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
    $GRID = create_grid()
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
        puts temp
        Draw.add_edge(temp.get(0,0), temp.get(1,0), temp.get(2,0), temp.get(0,1), temp.get(1,1), temp.get(2,1))
      when "circle"
        args = file.gets.chomp.split(" ")
        for i in (0...4); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.circle(args[0], args[1], args[2], args[3])
      when "hermite"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.hermite(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
      when "bezier"
        args = file.gets.chomp.split(" ")
        for i in (0...8); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.bezier(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
      when "box"
        args = file.gets.chomp.split(" ")
        for i in (0...6); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.box(args[0], args[1], args[2], args[3], args[4], args[5])
      when "sphere"
        args = file.gets.chomp.split(" ")
        for i in (0...4); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.sphere(args[0], args[1], args[2], args[3])
      when "torus"
        args = file.gets.chomp.split(" ")
        for i in (0...5); args[i] = args[i].to_f end
        puts "With arguments: "  + args.to_s if $DEBUGGING
        Draw.torus(args[0], args[1], args[2], args[3], args[4])
      when "clear"
        $EDGE_MAT = Matrix.new(4, 0)
        $POLY_MAT = Matrix.new(4, 0)
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
