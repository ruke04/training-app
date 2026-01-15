*** Variables ***
${HEADLESS}   False
${TRAINING_APP_TITLE}               //*[text()="🧪 Training App"]
${REG_USERNAME_FIELD}               //input[@id="reg_username"]
${REG_PASSWORD_FIELD}               //input[@id="reg_password"]
${SIGN_UP_BUTTON}                   //button[text()="Sign Up"]
${LOGIN_USERNAME}                   //input[@id="username"]
${LOGIN_PASSWORD}                   //input[@id="password"]
${LOGIN_BUTTON}                     //button[text()="Login"]
${LOGOUT_BUTTON}                    //button[text()='Logout']
${APP_URL}                          http://localhost:8080/
${NOTIFICATION_MESSAGE}             xpath=//*[@id="notification"]
${TABLE_ROWS}                       //tbody/tr[position() > 1]
${LAST_ROW}                         //tbody/tr[last()]
${USERS_LIST}                       //*[@id="users_list"]
${SHOW_ALL_USERS_BUTTON}            //button[text()="Show All Users"]
${REFRESH_PROFILE_BUTTON}           //button[contains(text(),"Refresh Profile")]
${OPEN_PROTECTED_SITE_BUTTON}       //button[text()="Open Protected Site"]
${COMPANY_LOGO}                     //img[@alt="EFEWALICOMMS OY Logo"]
${DELETE_USERNAME}               //input[@id="delete_username"]
${DELETE_BTN}                   //button[text()="Delete User"]
${DELETE_NOTE}                  //*[@id="confirmModal"]/div
${DELETE_CONFIRM}               //button[text()="Confirm"]
${LOGOUT_PROTECTED_SITE_BUTTON}    //html/body/div[6]/header/div[2]/button
${WHY_US_BUTTON}                  //html/body/div[6]/header/nav/a[2]