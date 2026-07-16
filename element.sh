#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

INPUT=$1

if [[ $INPUT =~ ^[0-9]+$ ]]
then
  RESULT=$($PSQL "
    SELECT
      e.atomic_number,
      e.name,
      e.symbol,
      t.type,
      p.atomic_mass,
      p.melting_point_celsius,
      p.boiling_point_celsius
    FROM elements AS e
    INNER JOIN properties AS p
      ON e.atomic_number = p.atomic_number
    INNER JOIN types AS t
      ON p.type_id = t.type_id
    WHERE e.atomic_number = $INPUT
    LIMIT 1;
  ")
else
  RESULT=$($PSQL "
    SELECT
      e.atomic_number,
      e.name,
      e.symbol,
      t.type,
      p.atomic_mass,
      p.melting_point_celsius,
      p.boiling_point_celsius
    FROM elements AS e
    INNER JOIN properties AS p
      ON e.atomic_number = p.atomic_number
    INNER JOIN types AS t
      ON p.type_id = t.type_id
    WHERE e.symbol = '$INPUT'
       OR e.name = '$INPUT'
    LIMIT 1;
  ")
fi

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit
fi

IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
