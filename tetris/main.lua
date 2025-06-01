--board size
BOARD_WIDTH = 10
BOARD_HEIGHT = 20
TILE_SIZE = 32


--falling piece timing
FALL_TIME = 0.5       -- time interval
FALL_TIMER = 0        -- current timer counting time since last drop

local gameOver = false
local score = 0



--initialize empty board
local board = {}
for y = 1, BOARD_HEIGHT do
    board[y] = {}
    for x = 1, BOARD_WIDTH do
        board[y][x] = 0
    end
end



--sets the window size based on board size
function love.load()
    local windowWidth = BOARD_WIDTH * TILE_SIZE
    local windowHeight = BOARD_HEIGHT * TILE_SIZE

    love.window.setMode(windowWidth, windowHeight)
    love.window.setTitle("Tetris")
end



-- four types of blocks
local tetrisShapes = {
    --square yellow
    {
        shape = {
            {1, 1},
            {1, 1}
        },
        color = {1, 1, 0}
    },

    --I blue
    {
        shape = {
            {1, 1, 1, 1}
        },
        color = {0, 1, 1}
    },

    --L orange
    {
        shape = {
            {1, 0},
            {1, 0},
            {1, 1}
        },
        color = {1, 0.5, 0}
    },

    --T green
    {
        shape = {
            {1, 1, 1},
            {0, 1, 0}
        },
            color = {0.3, 1, 0.3}
    }
}


function checkCollision(shape, posX, posY)
    for py = 1, #shape do
        for px = 1, #shape[py] do
            if shape[py][px] == 1 then
                local x = posX + px -1
                local y = posY + py -1

                
                --chceck collision with down border
                if y > BOARD_HEIGHT then
                    return true
                end

                --chceck collision with left and right border
                if x < 1 or x > BOARD_WIDTH then
                    return true
                end

                --chceck collision with other blocks
                if y >= 1 and board[y][x] and board[y][x] ~= 0 then

                    return true
                end
            end
        
        end
    end

    return false
end

function spawnRandomPiece()
    --picking random shape 
    local i = love.math.random(1, #tetrisShapes)
    local def = tetrisShapes[i]
    --spawn a new piece positioned horizontally at the center
    local piece = {
        shape = def.shape,
        color = def.color,
        x = math.floor(BOARD_WIDTH / 2 - #def.shape[1] / 2) + 1,
        y = 1
    }
    --if shape colllides after spawn immediately end the game
    if checkCollision(piece.shape, piece.x, piece.y) then
        gameOver = true
    end

    return piece
end





local currentPiece = spawnRandomPiece()


-- handles key to control the falling shape, and checking if there is no collision
function love.keypressed(key)
    if key == "left" then
        if not checkCollision(currentPiece.shape, currentPiece.x - 1, currentPiece.y) then
            currentPiece.x = currentPiece.x - 1
        end
    elseif key == "right" then
        if not checkCollision(currentPiece.shape, currentPiece.x + 1, currentPiece.y) then
            currentPiece.x = currentPiece.x + 1
        end
    elseif key == "down" then
        if not checkCollision(currentPiece.shape, currentPiece.x, currentPiece.y + 1) then
            currentPiece.y = currentPiece.y + 1
        end
         --rotate piece clockwise if no collision
    elseif key == "up" then
        local rotated = rotateShape(currentPiece.shape)
        if not checkCollision(rotated, currentPiece.x, currentPiece.y) then
            currentPiece.shape = rotated
        end
    end
    
end

--returns a new rotated shape table 
function rotateShape(shape)

    local newShape = {}
    local rows = #shape
    local cols = #shape[1]

    for x = 1, cols do
        newShape[x] = {}
        for y = rows, 1, -1 do
            newShape[x][rows - y + 1] = shape[y][x]
        end
    end

    return newShape
end




--checks for and removes any full lines from the board, and returns the numbers of lines cleared,
--shifts all rows aboved clearded lines down
function clearFullLines()

    local y = BOARD_HEIGHT
    local linesCleared = 0

    while y>= 1 do
        local full = true

        --check if the row is full (no zeros)
        for x = 1, BOARD_WIDTH do
            if board[y][x] == 0 then
                full = false
                break
            end
        end

        if full then
             --remove full row
            table.remove(board, y)
            local newRow = {}
            for i = 1, BOARD_WIDTH do
                newRow[i] = 0
            end
            table.insert(board, 1, newRow)
              --count cleared lines (it is  used to count score)
            linesCleared = linesCleared + 1
        else
            y = y - 1
        end
    end

    return linesCleared
end




--handles automatic falling of the current piece and locking it into the board
function love.update(delta)
    --stop the updates if there is game over
    if gameOver then return end
    FALL_TIMER = FALL_TIMER + delta
    
    --time to move the piece down
    if FALL_TIMER >=FALL_TIME then
        FALL_TIMER = 0

        --try to move the piece down by 1 if thre is no collison
        if not checkCollision(currentPiece.shape, currentPiece.x, currentPiece.y + 1) then
            currentPiece.y = currentPiece.y + 1
        else
           --if can't move down, put the shape to the board 
            for py = 1, #currentPiece.shape do
                for px = 1, #currentPiece.shape[py] do
                    if currentPiece.shape[py][px] == 1 then
                        local x = currentPiece.x + px - 1
                        local y = currentPiece.y + py - 1

                        if y >= 1 and y <= BOARD_HEIGHT and x >= 1 and x <= BOARD_WIDTH then
                            board[y][x] = currentPiece.color

                        end
                    end
                end
            end

            --clear full lines and update score
           local lines = clearFullLines()
            score = score + (lines *100)

            --spawn new random piece
            currentPiece = spawnRandomPiece()
        end
    end
end





--draws game frame: board, current piece, score, and "game over" message
function love.draw()
    --draw board grid and placed blocks
    for y = 1, BOARD_HEIGHT do
        for x = 1, BOARD_WIDTH do
           local color = board[y][x]
            if color == 0 then
                color = {0.4, 0.4, 0.4} -- empty cells
            end

            love.graphics.setColor(color)
            love.graphics.rectangle("line", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
     --draw the currently falling piece
    for py = 1, #currentPiece.shape do
        for px = 1, #currentPiece.shape[py] do
            if currentPiece.shape[py][px] == 1 then

                local x = currentPiece.x + px - 1
                local y = currentPiece.y + py - 1

                --fill the cell with the piece's color
                love.graphics.setColor(currentPiece.color) --yellow
                love.graphics.rectangle("fill", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)

                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("line", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            end
        end
    end
    --score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)


    --game over handler
    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, 300, BOARD_WIDTH * TILE_SIZE, "center")
    end
end