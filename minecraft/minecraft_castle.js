
//build spiral floor
function buildFloor (width: number, slot: number, position: Position) {
    //teleport agent
    agent.teleport(position, WEST)

    //load planks, one for floor, one fo roof
    agent.setItem(PLANKS_SPRUCE, 64, 1)
    agent.setItem(PLANKS_DARK_OAK, 64, 5)
    agent.setSlot(slot)
    while (width != 0) {
        for (let index = 0; index < 4; index++) {
            for (let index = 0; index < width - 1; index++) {
                agent.destroy(DOWN)
                agent.collectAll()
                agent.place(DOWN)
                agent.move(FORWARD, 1)
            }
            agent.destroy(DOWN)
            agent.collectAll()
            agent.place(DOWN)
            agent.turn(RIGHT)
        }
        agent.move(RIGHT, 1)
        agent.move(FORWARD, 1)
        width += -2
    }
}

//build castle walls
function buildWalls (length: number, height: number) {
    //teleport to corner
    agent.teleport(world(0, 0, 0), WEST)
    //load blocks
    agent.setItem(COBBLESTONE, 64, 2)
    agent.setItem(STONE_BRICKS, 64, 3)
    agent.setSlot(2)
    //build 4 sides
    for (let index = 0; index < 4; index++) {
        for (let i = 0; i <= length - 2; i++) {
            //(i+1)%3=>alt slot and lower
            if ((i + 1) % 3 == 0) {
                agent.setSlot(3)
            } else {
                agent.setSlot(2)
            }
            h = height - (((i + 1) % 3 === 0) ? 1 : 0)
            for (let index = 0; index < h; index++) {
                agent.move(UP, 1)
                agent.place(DOWN)
            }
            agent.move(FORWARD, 1)
            for (let index = 0; index < h; index++) {
                agent.move(DOWN, 1)
            }
        }
        agent.turn(RIGHT_TURN)
        agent.move(FORWARD, 1)
        agent.move(RIGHT, 1)
    }
}

//main build command
player.onChat("run", function () {
    buildFloor(20, 1, world(0, 0, 0))
    buildWalls(20, 10)
    //crate roof
    buildFloor(18, 5, world(0, 8, -1))
    //create door
    agent.teleport(world(2, 0, -9), WEST)
    agent.destroy(FORWARD)
    agent.move(UP, 1)
    agent.destroy(FORWARD)
    agent.move(DOWN, 1)
    agent.setItem(SPRUCE_DOOR, 55, 6)
    agent.setSlot(6)
    agent.place(FORWARD)
})

let height = 0
let h = 0
let width = 0
let position = null