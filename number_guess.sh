#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=guess_users -t --no-align -c"
# generate random number between 1 and 1000
ANSWER=$((1 + RANDOM % 1000))

# prompt and read username
echo "Enter your username:"
read USERNAME

# check username against database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")

if [[ -z $USER_ID ]];then
  # insert user into users
  INSERTED_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME');")
  # pull user_id from inserted user
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
  #new user message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # query variables needed for message
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER_ID;")
  # returning user message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# prompt and read guess
echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1


while true;
do
  # check if guess is a number
  if [[ ! $GUESS =~ [0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS -gt $ANSWER ]]; then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $ANSWER ]]; then
      echo "It's higher than that, guess again:"
    else
      # break loop if mew guess is correct
      break
    fi
  fi
  # increment guess count
  ((GUESS_COUNT++))
  read GUESS
done

# if guess is correct after breaking out of loop
echo "You guessed it in $GUESS_COUNT tries. The secret number was $ANSWER. Nice job!"

# insert game data once game is finished
INSERTED_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES($USER_ID, $GUESS_COUNT);")
