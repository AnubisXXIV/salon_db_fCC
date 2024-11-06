#!/bin/bash
#
# GET RID OF SELF LOOPS WHEN ENTERING BAD INPUT AS THE FIRST OPTION
#
PSQL="psql --username=freecodecamp --dbname=salon -t -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

#get services
SERVICES=$($PSQL "SELECT * FROM services")

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  #get user input
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    2) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    3) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    4) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    5) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    6) SCHEDULE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    *) MAIN_MENU "I could not find that service. What would you like today?"
  esac
}

SCHEDULE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #query db by phone number
  CUSTOMER_NAME_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if new customer
  if [[ -z $CUSTOMER_NAME_RESULT ]]
  then
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #add customer to db
    CUSTOMER_INSERT=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  CLEAN_SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//')
  CLEAN_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//')
  
  echo -e "\nWhat time would you like your $CLEAN_SERVICE_NAME, $CLEAN_CUSTOMER_NAME?"
  #get time
  read SERVICE_TIME
  # insert appointment in db
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $CLEAN_SERVICE_NAME at $SERVICE_TIME, $CLEAN_CUSTOMER_NAME."
}

MAIN_MENU