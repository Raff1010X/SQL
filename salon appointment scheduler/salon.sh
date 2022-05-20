#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Print welcome message
echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n" 

MAIN_MENU() {
  
  # Print message argument if provided
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Read services from database
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "Sorry. No available services. Try again later."
  else
    # Print list of services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID EMPTY SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    # Ask for service input
    read SERVICE_ID_SELECTED
    
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
      then
        # Send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        # Check if service input
        SERVICE_ID_SELECTED_DB=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
        #if not found
        if [[ -z $SERVICE_ID_SELECTED_DB ]]
        then
          # Send to main menu
          MAIN_MENU "I could not find that service. What would you like today?"
        else
          # Book service
          BOOK_SERVICE
        fi
    fi
  fi

}

BOOK_SERVICE(){

  # Ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  # Read customer id from db
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  
  # If customer is not in database
  if [[ -z $CUSTOMER_ID ]]
  then
    # Ask for customer name input
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # Write new customer to database
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    # Read new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  else
  # ELSE Read customer name from database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  fi

  # Ask for time input
  echo -e "\nWhat time would you like your service, $CUSTOMER_NAME" 
  read SERVICE_TIME

  # Write appointment to database
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id , time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")
  if [[ $INSERT_APPOINTMENT ]]
  then
    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
