require 'ruby2d'
class Player
  HEIGHT=32
  WIDTH=32
  GRAVITY=0.5 
  JUMP_V=-12 
  MOVE=5 
  FW=16 
  FH=16
  attr_reader :x, :y, :width, :height, :sprite

  def initialize(x:, y:)
    #position, physics, sprite
    @x,@y,@width,@height = x,y,WIDTH,HEIGHT
    @vx=@vy=0; @onGround=@prev=false; @flip=:right

    @sprite = Sprite.new(
      'assets/mario.png',
      x: @x, 
      y: @y,
      width: @width, 
      height: @height,
      clip_width: FW, 
      clip_height: FH,
      time: 100,
      animations: { walk:1..3, jump:4..4, stay:0..0 }
    )
    @sprite.play(animation: :stay)
  end

  #player moves

  def moveLeft
    
    @vx = -MOVE; @flip = :left
    @sprite.play(animation: :walk, loop: true, flip: :horizontal) if @onGround
  end

  def moveRight
    @vx = MOVE;  @flip = :right
    @sprite.play(animation: :walk, loop: true) if @onGround
  end

  def stopH
    @vx = 0
    return unless @onGround
    @sprite.play(animation: :stay, flip: (@flip == :left ? :horizontal : nil))
  end

  def jump
    return unless @onGround
    @vy = JUMP_V; @onGround = false
    @sprite.play(animation: :jump, loop: true, flip: (@flip == :left ? :horizontal : nil))
  end

  
  def update(plats)
    # track ground state
    @prev, @onGround = @onGround, false

    # horizontal moves and collisions
    @x += @vx; @sprite.x = @x
    plats.each do |p|
      next unless collide_with?(p)
      @x = @vx > 0 ? p.x - @width : p.x + p.width
      @vx = 0; @sprite.x = @x
    end

    #apply gravity
    @vy += GRAVITY

    # vertical moves and collisions
    @y += @vy; @sprite.y = @y
    plats.each do |p|
      next unless collide_with?(p)
      if @vy > 0
        # landed
        @y = p.y - @height; @onGround = true
      elsif @vy < 0
        # hit head
        @y = p.y + p.height
      end
      @vy = 0; @sprite.y = @y
      # on-land animation
      unless @prev
        if @vx < 0 then moveLeft
        elsif @vx > 0 then moveRight
        else stopH end
      end
    end

    #jump animation
    unless @onGround
      @sprite.play(animation: :jump, loop: true, flip: (@flip == :left ? :horizontal : nil))
    end
  end



  def collide_with?(p)
    # AABB collison detect
    (@x + @width)  > p.x &&
    @x            < (p.x + p.width) &&
    (@y + @height) > p.y &&
    @y            < (p.y + p.height)
  end
end
