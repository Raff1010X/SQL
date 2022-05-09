#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games restart identity")

NUM_OF_TEAMS=0
NUM_OF_GAMES=0

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then

    TEAM_WINNER=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")

    if [[ $TEAM_WINNER = "" ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        (( NUM_OF_TEAMS++ ))
        echo Inserted into teams - $NUM_OF_TEAMS, $WINNER
      fi

    fi
    
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    TEAM_OPPONENT=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

    if [[ $TEAM_OPPONENT = "" ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        (( NUM_OF_TEAMS++ ))
        echo Inserted into teams - $NUM_OF_TEAMS, $OPPONENT
      fi

    fi

    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")

    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      (( NUM_OF_GAMES++ ))
      echo Inserted games $NUM_OF_GAMES, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
    fi

  fi
done
