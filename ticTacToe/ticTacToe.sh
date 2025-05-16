#!/bin/bash

board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
current_player="X"


draw(){
    echo " 1 | 2 | 3 "
    echo "---+---+---"
    echo " 4 | 5 | 6 "
    echo "---+---+---"
    echo " 7 | 8 | 9 "
    echo "         "
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
}

check_win(){
    if [[ "${board[0]}" = "$current_player" && "${board[1]}" = "$current_player" && "${board[2]}" = "$current_player" ]] ||
   [[ "${board[3]}" = "$current_player" && "${board[4]}" = "$current_player" && "${board[5]}" = "$current_player" ]] ||
   [[ "${board[6]}" = "$current_player" && "${board[7]}" = "$current_player" && "${board[8]}" = "$current_player" ]] ||
   [[ "${board[0]}" = "$current_player" && "${board[3]}" = "$current_player" && "${board[6]}" = "$current_player" ]] ||
   [[ "${board[1]}" = "$current_player" && "${board[4]}" = "$current_player" && "${board[7]}" = "$current_player" ]] ||
   [[ "${board[2]}" = "$current_player" && "${board[5]}" = "$current_player" && "${board[8]}" = "$current_player" ]] ||
   [[ "${board[0]}" = "$current_player" && "${board[4]}" = "$current_player" && "${board[8]}" = "$current_player" ]] ||
   [[ "${board[2]}" = "$current_player" && "${board[4]}" = "$current_player" && "${board[6]}" = "$current_player" ]]; then
        echo "$current_player wins!"

        exit 0
    fi
}

check_draw(){
    for i in "${board[@]}"; do
        if [ "$i" = "-" ]; then
            return
       
        fi
    done
    echo "Draw!"
    exit 0
}

player_input(){
    echo "Player $current_player turn"
    read turn
    turn=$((turn - 1))

    while [ "${board[$turn]}" != "-" ]; do
        draw
        echo "This place is occupied, try another"
        read -p "Choose a different spot (1-9): " turn
    done

    board[$turn]=$current_player
    draw
    check_win
    check_draw
    if [ "$current_player" = "X" ]; then
        current_player="O"
    else
        current_player="X"
    fi

    player_input
}



draw
player_input