#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Resetting state of the database

echo $($PSQL "TRUNCATE TABLE teams, games;");

# Reading values from CSV file into variables

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
  # Adding a winner to the teams table
  # Ommiting the first line with columns descriptors
  if [[ $WINNER != "winner" ]]
  then
    # Getting winner ID (if already in the database)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    # Case for winner that is not in the database
    if [[ -z $WINNER_ID ]]
    then
      # Result of adding a winner to the database
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');");
      # If added succsessfully
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]] 
      then
        echo "Winner: $WINNER inserted into teams table."
        # Getting ID of newly added winner
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      else 
        echo "Operation unsuccessful when adding winner."
      fi
    fi
  fi

  # Adding opponent to the teams table
  if [[ $OPPONENT != "opponent" ]] 
  then
    # Getting opponent id from teams table (if already in the database)
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    # Case for opponent that is not yet in the database
    if [[ -z $OPPONENT_ID ]] 
    then
      # Result of adding an opponent to the database
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      # If added succsessfully
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]] 
      then
        echo "Opponent: $OPPONENT inserted into teams table."
        # Getting ID of newly added opponent
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      else 
        echo "Operation unsuccessful when adding opponent."
      fi
    fi
  fi

  # Adding game info to the games table.
  if [[ -n $WINNER_ID ]] && [[ -n $OPPONENT_ID ]]
  then
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Game info (between $WINNER and $OPPONENT from $YEAR) inserted successfully."
    fi
  fi
done

# Variables declaration

# Adding country to teams table (if it is not there)
