#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read NAME
USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$NAME'")
COUNT=$($PSQL "SELECT COUNT(user_id) FROM result_game INNER JOIN users USING(user_id) WHERE username = '$NAME'")
MINGUESSES=$($PSQL "SELECT MIN(number_guesses) FROM result_game INNER JOIN users USING(user_id) WHERE username = '$USERNAME'")
if [[ -z $USERNAME ]]
then 
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
else 
  echo "Welcome back, $NAME! You have played $COUNT games, and your best game took $MINGUESSES guesses."
fi

NUMBER=$((1 + $RANDOM % 1000))
echo $NUMBER

echo "Guess the secret number between 1 and 1000:"
read GUESS

FUNC_GUESS_NUMBER () {
  while [[ $GUESS =~ ^[0-9]+$ ]]
  do
    if [[ $GUESS > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      GUESSES=$(($GUESSES + 1))
    elif [[ $GUESS < $NUMBER ]] 
    then
      echo "It's higher than that, guess again:"
      read GUESS
      GUESSES=$(($GUESSES + 1))
    else
      GUESSES=$(($GUESSES + 1))
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$NAME'")
      INSERT_GUESSES=$($PSQL "INSERT INTO result_game(user_id, number_guesses) VALUES("$USER_ID", "$GUESSES")")
      echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    break  
    fi
  done
}

FUNC_GUESS_NUMBER

while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ && ! $GUESS == $NUMBER ]]
  then
    FUNC_GUESS_NUMBER
  fi
done
