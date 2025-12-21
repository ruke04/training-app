*** Variables ***
${HEADLESS}   False
${TRAINING_APP_TITLE}            //*[text()="🧪 Training App"]
${REG_USERNAME_FIELD}           //input[@id="reg_username"]
${REG_PASSWORD_FIELD}           //input[@id="reg_password"]
${SIGN_UP_BUTTON}               //button[text()="Sign Up"]
${LOGIN_USERNAME}               //input[@id="username"]
${LOGIN_PASSWORD}               //input[@id="password"]
${LOGIN_BUTTON}                 //button[text()="Login"]
${LOGOUT_BUTTON}                //button[text()='Logout']
${APP_URL}                  http://localhost:8080/
${NOTIFICATION_MESSAGE}     xpath=//*[@id="notification"]
${TABLE_ROWS}                  css=table tbody tr:has(td)
${LAST_ROW}                 css=#users_list tr:last-child
${USERS_LIST}               css=#users_list > div:first-of-type 
${SHOW_ALL_USERS_BUTTON}      //button[text()="Show All Users"]




