require 'ruby2d'
class Point
  attr_reader :x, :y, :width, :height

  def initialize(x:, y:, image_path: 'assets/coin.png',
                 frame_w: 16, frame_h: 16, time: 300,
                 width: 32, height: 32)
    @x,@y,@width,@height = x,y,width,height
    # create animating sprite
    @sprite = Sprite.new(
      image_path,
      x:            @x,  y: @y,
      width:        @width,  height: @height,
      clip_width:   frame_w, clip_height: frame_h,
      time:         time,    loop: true
    )
    @sprite.play    # start animation
  end

  #shift sprite by camera offset
  def set_screen_position(cx)
    @sprite.x = @x - cx
    @sprite.y = @y
  end

  #remove sprite when collected
  def remove
    @sprite.remove
  end
end
