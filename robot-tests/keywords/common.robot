*** Settings ***
Library    Browser
Library    String
Resource    ../pageobject/training_app_page.robot

*** Variables ***
${HEADLESS}         false
${FRONTEND_URL}     http://localhost:8080

*** Keywords ***

Launch Training App
    New Browser  Chromium  headless=${HEADLESS}
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${FRONTEND_URL}
    # Handle ngrok splash page if present (only when using ngrok URL)
    ${ngrok_button_exists}=    Run Keyword And Return Status    Wait For Elements State    text=Visit Site    visible    timeout=3s
    Run Keyword If    ${ngrok_button_exists}    Click    text=Visit Site
    Wait For Element To Be Visible   ${TRAINING_APP_TITLE}   timeout=10s

Wait For Element To Be Visible
    [Arguments]    ${locator}    ${timeout}=None
    Wait For Elements State  ${locator}    visible     timeout=${timeout}

Enter Username
    [Arguments]    ${username}
    Wait For Element To Be Visible   ${REG_USERNAME_FIELD}   timeout=10s
    Type Text  ${REG_USERNAME_FIELD}  ${username}

Enter Password
    [Arguments]    ${password}
    Wait For Element To Be Visible   ${REG_PASSWORD_FIELD}   timeout=10s
    Type Text  ${REG_PASSWORD_FIELD}  ${password}

Click Sign Up Button
    Wait For Element To Be Visible   ${SIGN_UP_BUTTON}   timeout=10s
    Click  ${SIGN_UP_BUTTON}

Enter Login Username
    [Arguments]    ${username}=None
    Wait For Element To Be Visible   ${LOGIN_USERNAME}   timeout=10s
    Run Keyword If    '${username}' != 'None'    Type Text    ${LOGIN_USERNAME}    ${username}

Enter Login Password
    [Arguments]    ${password}=None
    Wait For Element To Be Visible   ${LOGIN_PASSWORD}   timeout=10s
    Run Keyword If    '${password}' != 'None'    Type Text  ${LOGIN_PASSWORD}  ${password}

Click Login Button
    Wait For Element To Be Visible   ${LOGIN_BUTTON}   timeout=10s
    Click  ${LOGIN_BUTTON}

Click Logout Button
    Click  ${LOGOUT_BUTTON}

Click Show all user Button
    Wait For Element To Be Visible   ${SHOW_ALL_USERS_BUTTON}  timeout=10s
    Click  ${SHOW_ALL_USERS_BUTTON}

Click Refresh Profile Button
    Wait For Element To Be Visible   ${REFRESH_PROFILE_BUTTON}  timeout=10s
    Click  ${REFRESH_PROFILE_BUTTON}
