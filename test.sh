fn_inputs() {
    echo -ne "\nPlease enter a valid email: "
    read EMAIL

    #  Email validation
    local regex="^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$"

    
    if [[ $EMAIL =~ $regex ]]; then
        echo -e "\nYour email address is '${EMAIL}'."
        echo -n "Is that okay? (y/n): "
        read confirmation

        
        if [[ $confirmation == [yY] ]]; then
            echo -e "\nEmail confirmed: ${EMAIL}"
            
        elif [[ $confirmation == [nN] ]]; then
            echo -e "\nOkay."
            fn_inputs  
        else
            echo -e "Invalid input. \nPlease enter 'y' for yes or 'n' for no.\n"
            fn_inputs  
        fi
    else
        echo -ne "\nInvalid email address.\nPlease try again.\n"
        fn_inputs  
    fi
}


fn_inputs
