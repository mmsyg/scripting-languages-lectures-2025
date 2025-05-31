// build spiral floor
function buildFloor (width: number, slot: number, position: Position) {
    // teleport agent
    agent.teleport(position, WEST)
    // load planks, one for floor, one fo roof
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
// build castle walls
function buildWalls (length: number, height: number) {
    // teleport to corner
    agent.teleport(world(0, 0, 0), WEST)
    // load blocks
    agent.setItem(COBBLESTONE, 64, 2)
    agent.setItem(STONE_BRICKS, 64, 3)
    agent.setItem(GLASS_PANE, 64, 4)
    // compute middle pillar indices, they will be on the midle
    mid1 = Math.floor((length - 1) / 2) - 1
    mid2 = Math.floor((length - 1) / 2)
    for (let index = 0; index < 4; index++) {
        for (let i = 0; i <= length - 1 - 1; i++) {
            let slot = ((i + 1) % 3 === 0) ? 3 : 2
agent.setSlot(slot)
            h = height - (((i + 1) % 3 === 0) ? 1 : 0)
            if (i == mid1 || i == mid2) {
                // lower part
                lower = Math.floor((h - 3) / 2)
                for (let index = 0; index < lower; index++) {
                    agent.move(UP, 1)
                    agent.place(DOWN)
                }
                // window
                agent.setSlot(4)
                for (let index = 0; index < 3; index++) {
                    agent.move(UP, 1)
                    agent.place(DOWN)
                }
                // upper part (reuse slot)
                agent.setSlot(slot)
                for (let index = 0; index < h - lower - 3; index++) {
                    agent.move(UP, 1)
                    agent.place(DOWN)
                }
                agent.move(FORWARD, 1)
                // descend and step forward
                agent.move(DOWN, h)
            } else {
                // normal pillar
                for (let index = 0; index < h; index++) {
                    agent.move(UP, 1)
                    agent.place(DOWN)
                }
                // move to next pillar
                agent.move(FORWARD, 1)
                agent.move(DOWN, h)
            }
        }
        // turn corner and step to next wall
        agent.turn(RIGHT)
        agent.move(FORWARD, 1)
        agent.move(RIGHT, 1)
    }
}
// main build command
player.onChat("run", function () {
    digMoat()
    buildWalls(20, 10)
    // crate roof
    buildFloor(18, 5, world(0, 8, -1))
    // create door
    agent.teleport(world(2, 0, -9), WEST)
    agent.destroy(FORWARD)
    agent.move(UP, 1)
    agent.destroy(FORWARD)
    agent.move(DOWN, 1)
    agent.setItem(SPRUCE_DOOR, 55, 6)
    agent.setSlot(6)
    agent.place(FORWARD)
})
function digMoat () {
    //crate moat using block.fill
    blocks.fill(
    WATER,
    world(8, -1, 6),
    world(-26, -4, -26),
    FillOperation.Replace
    )
    //crate floor using block.fill
    blocks.fill(
    PLANKS_SPRUCE,
    world(1, -1, 0),
    world(-18, -4, -19),
    FillOperation.Replace
    )
    //crate bridge using block.fill
    blocks.fill(
    POLISHED_ANDESITE,
    world(2, -1, -8),
    world(9, -1, -10),
    FillOperation.Replace
    )
    agent.collectAll()
}
let lower = 0
let h = 0
let mid2 = 0
let mid1 = 0
let width = 0
let height = 0
let position = null
let mid12 = 0
let mid22 = 0
let j = 0
let lower2 = 0
