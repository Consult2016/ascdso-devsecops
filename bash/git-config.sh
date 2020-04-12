git-config.sh

   # If git user not already configured ...
      # note "$( git config --list )"
   RESPONSE="$( git config --get user.email )"
   if [ -n "${RESPONSE}" ]; then  # not found
      if [[ $RESPONSE == "$GitHub_USER_EMAIL" ]]; then  # already defined:
         note "GitHub_USER_EMAIL being configured ..."
      else
         git config user.email "$GitHub_USER_EMAIL"
      fi
      info "$( git config --get user.email )"
   fi

   RESPONSE="$( git config --get user.name )"
   if [ -n "${RESPONSE}" ]; then  # not found
      if [[ $RESPONSE == "$GitHub_USER_NAME" ]]; then  # already defined:
         info "GitHub_USER_EMAIL being configured ..."
      else
         git config user.name  "$GitHub_USER_NAME"
      fi
      info "$( git config --get user.email )"
   fi


   #if [ ! -f ".env" ]; then
   #   cp .env.example  .env
   #else
   #   warning "no .env file"
   #fi
