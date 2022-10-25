#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~"

#echo -e "Welcome to My Salon, how can I help you?\n"

PSQL="psql --username=postgres --dbname=salon -t --no-align -c"

#MAIN MENU
MAIN_MENU(){
  [[ -z $1 ]] && echo -e "\nWelcome to My Salon, how can I help you?\n" || echo -e "\n$1"
  MENU_OPTIONS=$($PSQL "SELECT * FROM services")

  echo $MENU_OPTIONS  | sed -r 's/\|/) /g' | sed -r 's/([0-9]+[^0-9]+)/\1\n/g'  
  read SERVICE_ID_SELECTED

  CONTROLLER_MAIN_MENU
}

#CONTROLLER MAIN_MENU
CONTROLLER_MAIN_MENU(){
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU 'I could not find that service. What would you like today?'
  else
    SCHEDULE
  fi
}

SCHEDULE(){
  echo "What's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    REGISTER_NEW_CUSTOMER
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  fi

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  INSERT_APPOITMENT
}

REGISTER_NEW_CUSTOMER(){
  INSERTED_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  if [[ ! $INSERTED_NEW_CUSTOMER == "INSERT 0 1" ]]
  then
    echo -e "\nOcorreu algum erro na hora de cadastrar o novo cliente no banco de dados. Tente novamente mais tarde.\n"
  fi
}

INSERT_APPOITMENT(){
  INSERTED_NEW_APPOITMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  if [[ ! $INSERTED_NEW_APPOITMENT == "INSERT 0 1" ]]
  then
    echo -e "\nOcorreu algum erro na hora de cadastrar o novo agendamento no banco de dados. Tente novamente mais tarde.\n"
  fi
}

MAIN_MENU