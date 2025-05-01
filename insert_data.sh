#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.


echo $($PSQL "TRUNCATE games,teams RESTART IDENTITY")
CONTAINS_ELEMENT() {
  elem="$1"
  shift
  arr=("$@")  # Grab the rest of the arguments as an array

  for i in "${arr[@]}"; do
    [[ "$i" == "$elem" ]] && return 0
  done
  return 1
}

 TEAMS=()
 while IFS="," read _ _ WINNER OPPONENT _ _; 
  do
  
  if ! CONTAINS_ELEMENT "$WINNER" "${TEAMS[@]}";
  then
    TEAMS+=("$WINNER")
    INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')" );
  if [[ $INSERT_TEAM == "INSERT 0 1" ]]
  then
    echo Inserted into teams, $WINNER
  fi
  fi
  if ! CONTAINS_ELEMENT "$OPPONENT" "${TEAMS[@]}" ;
  then
  TEAMS+=("$OPPONENT")
  INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')" );
  if [[ $INSERT_TEAM == "INSERT 0 1" ]]
  then
    echo Inserted into teams, $OPPONENT
  fi
  fi


done < <(tail -n +2 games.csv)



tail -n +2 games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
if [[ -n "$WINNER_ID" && -n "$OPPONENT_ID" ]];
then
INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES('$YEAR','$ROUND','$WINNER_ID','$OPPONENT_ID','$WINNER_GOALS','$OPPONENT_GOALS')") 
echo Inserted into games, game_info:"$YEAR","$ROUND","$WINNER","$OPPONENT","$WINNER_GOALS","$OPPONENT_GOALS"
fi
done
