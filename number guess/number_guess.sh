#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=100
#$((1 + $RANDOM % 1000))

GUESS_GAME() {
  NUMBER_OF_GUESSES=0

  echo "Guess the secret number between 1 and 1000:"

  while [[ $GUESS_NUMBER != $SECRET_NUMBER ]]
  do
    read GUESS_NUMBER

    if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else

      if [ $GUESS_NUMBER -gt  $SECRET_NUMBER ]
      then
        echo "It's lower than that, guess again:"
      fi

      if [ $GUESS_NUMBER -lt $SECRET_NUMBER ]
      then
        echo "It's higher than that, guess again:"
      fi    

    fi
    NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
  done

  if [ $NUMBER_OF_GUESSES -lt $BEST_GAME ]
  then
    BEST_GAME=$NUMBER_OF_GUESSES
  fi

  SCORE=$($PSQL "UPDATE users SET best_game=$BEST_GAME, games_played=$GAMES_PLAYED WHERE username='$USERNAME';")
  
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

}

START_THE_GAME(){
  echo "Enter your username:"

  while [ -z $USERNAME ]
  do
    read USERNAME
    if [[ -z $USERNAME ]]
    then
      echo "Enter your username:"
    else
      USERNAME_DB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
    fi
  done

  if [[ -z $USERNAME_DB ]]
  then
    NEW_PLAYER=$($PSQL "INSERT INTO users (username, best_game, games_played) VALUES ('$USERNAME', 10000, 0);")
    GAMES_PLAYED=1
    BEST_GAME=10000
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GUESS_GAME
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    GAMES_PLAYED=$(($GAMES_PLAYED + 1))
    GUESS_GAME
  fi

}

START_THE_GAME
