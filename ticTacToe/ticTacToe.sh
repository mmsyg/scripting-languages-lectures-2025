#!/bin/bash

#initialize board as an array of 9 empty spots
board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
#start the game with X player
current_player="X"


bot_enabled=false


#display the main menu
menu() {
    echo "==== Tic Tac Toe ===="
    echo "1. New game"
    echo "2. Play vs Bot"
    echo "3. Load game"
    echo "4. Exit"
    echo "Choose option: "
    read  choice

    #handle menu choices
    case $choice in
        1) new_game ;;
        2) new_game_vs_bot ;;
        3) load_game ;;
        4) exit ;;
        *) echo "Bad choice :("; menu ;;
    esac
}

#draw the game board
draw(){
    clear 
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




#check if currrent player has won
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

        #return to menu after win
        menu
    fi
}

#function helper to check if there is a possibility of winning in next move
check_win_possibility() {
    local p=$1
    [[ "${board[0]}" = "$p" && "${board[1]}" = "$p" && "${board[2]}" = "$p" ]] ||
    [[ "${board[3]}" = "$p" && "${board[4]}" = "$p" && "${board[5]}" = "$p" ]] ||
    [[ "${board[6]}" = "$p" && "${board[7]}" = "$p" && "${board[8]}" = "$p" ]] ||
    [[ "${board[0]}" = "$p" && "${board[3]}" = "$p" && "${board[6]}" = "$p" ]] ||
    [[ "${board[1]}" = "$p" && "${board[4]}" = "$p" && "${board[7]}" = "$p" ]] ||
    [[ "${board[2]}" = "$p" && "${board[5]}" = "$p" && "${board[8]}" = "$p" ]] ||
    [[ "${board[0]}" = "$p" && "${board[4]}" = "$p" && "${board[8]}" = "$p" ]] ||
    [[ "${board[2]}" = "$p" && "${board[4]}" = "$p" && "${board[6]}" = "$p" ]]
}



#check if game is a draw
check_draw(){
    for i in "${board[@]}"; do
        if [ "$i" = "-" ]; then
            return  #if at least one cell is empty: not a draw
       
        fi
    done
    echo "Draw!"
    #return to menu after draw
    menu
}

#handle player's input and turn
player_input(){
    
    while true; do
        echo "Player $current_player turn 's' save, 'm' menu: "
        read turn

        #save game if player type 's'
        if [ "$turn" = "s" ]; then
            save_game
            continue
        fi

        #return to menu if player type 'm'
        if [ "$turn" = "m" ]; then
            menu
            return
        fi

        #chceck if input is valid (number 1-9)
        if ! [[ "$turn" =~ ^[1-9]$ ]]; then
            echo "Invalid choice. Select 1–9, 's' to save, or 'm' to return to the menu"
            continue
        fi

        index=$((turn - 1)) #convert human-readable position to array index (0–8)

         #check if chosen cell is already taken
        if [ "${board[$index]}" != "-" ]; then
            draw
            echo "This place is occupied, try another"
            continue
        fi
        
        board[$index]=$current_player #place the current player's symbol
        break
    done
    draw
    check_win
    check_draw

    #switch player
    if [ "$current_player" = "X" ]; then
        current_player="O"
    else
        current_player="X"
    fi
    if $bot_enabled && [ "$current_player" = "O" ]; then
        bot_move
        draw
        check_win
        check_draw
        current_player="X"
    fi
    
}

game_loop(){
    draw
    while true; do
        player_input
    done
}


#bot tunr logic
bot_move() {
    echo "Bot's turn..."
    sleep 1

    #chcecking if bot could win
    for i in {0..8}; do

        if [ "${board[$i]}" = "-" ]; then
            board[$i]=$current_player
            if check_win_possibility "$current_player"; then
            
             return
            fi
            board[$i]="-"
        fi
    done

    #chcecking if player could win and block
    opponent="X"
    for i in {0..8}; do

        if [ "${board[$i]}" = "-" ]; then
            board[$i]=$opponent
            if check_win_possibility "$opponent"; then
                board[$i]=$current_player
                return

            fi
            board[$i]="-"
        fi
    done

    #random move
    while true; do
        i=$((RANDOM % 9))
        if [ "${board[$i]}" = "-" ]; then
            board[$i]=$current_player
            return
        fi
    done
}




#starting new game, reseting board, and player
new_game(){
    board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
    current_player="X"
    bot_enabled=false
    game_loop

}

#starting new game with bot
new_game_vs_bot() {
    board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
    current_player="X"
    bot_enabled=true
    game_loop
}

#save the current board and player to txt file
save_game() {
    echo "${board[*]}" > saves.txt
    echo "$current_player" >> saves.txt
}

#load the game from txt file
load_game() {
    if [ ! -s saves.txt ]; then
        echo "Save is empty!"
        menu
        return
    fi
    IFS=' ' read -r -a board < saves.txt     #read board state from the first line     
    current_player=$(tail -n 1 saves.txt)     #read current player from last line  

    echo "Game load: "

    game_loop
}


#start by showing menu
menu