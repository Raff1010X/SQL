#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  ALL_ELEMENTS=$($PSQL "select atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type from elements left join properties using(atomic_number) left join types using(type_id) order by atomic_number;")
  while read A_NUMBER I SYMBOL I NAME I A_MASS I M_P_C I B_P_C I TYPE
    do
      if [[ $A_NUMBER = $1 ]] || [[ $SYMBOL = $1 ]] || [[ $NAME = $1 ]]
      then
        ELEMENT_IN_DATABASE=true
        echo "The element with atomic number $A_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $A_MASS amu. $NAME has a melting point of $M_P_C celsius and a boiling point of $B_P_C celsius."
      fi
    done <<< "$ALL_ELEMENTS"
    if [[ ! $ELEMENT_IN_DATABASE ]]
    then
      echo "I could not find that element in the database."
    fi
fi
