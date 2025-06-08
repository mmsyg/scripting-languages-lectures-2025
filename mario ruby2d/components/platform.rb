require 'ruby2d'
class Platform
  attr_reader :x, :y, :width, :height

  def initialize(x:, y:, width:, height:, tile_path: 'assets/block.png', tile_w: 32, tile_h: 32)
    # store params
    @x,@y,@width,@height,@tile_path,@tile_w,@tile_h = x,y,width,height,tile_path,tile_w,tile_h
    @tiles = []
    # compute how many rows/cols of tiles
    rows = (0..(@height - 1) / @tile_h)
    cols = (0..(@width  - 1) / @tile_w)


    rows.each do |r| # for each row
      cols.each do |c| # for each col
        # full-tile or leftover width/height
        w = (c < @width  / @tile_w ? @tile_w : @width  % @tile_w)
        h = (r < @height / @tile_h ? @tile_h : @height % @tile_h)
        # world coordinates
        wx, wy = @x + c * @tile_w, @y + r * @tile_h
        # create and store image
        @tiles << {
          img:     Image.new(@tile_path, x: wx, y: wy, width: w, height: h),
          world_x: wx, world_y: wy
        }
        
      end
    end
  end
  #shift all tiles by camera offset
  def set_screen_position(cx)
    
    @tiles.each { |t| t[:img].x = t[:world_x] - cx; t[:img].y = t[:world_y] }
  end
end
