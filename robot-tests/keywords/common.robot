*** Settings ***
Library    Browser
Resource    ../pageobject/training_app_page.robot

*** Keywords ***

Launch Training App
    New Browser  Chromium  headless=${HEADLESS}
    New Page    http://localhost:8080
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
    [Arguments]    ${username}
    Wait For Element To Be Visible   ${LOGIN_USERNAME}   timeout=10s
    Type Text  ${LOGIN_USERNAME}  ${username}

Enter Login Password
    [Arguments]    ${password}
    Wait For Element To Be Visible   ${LOGIN_PASSWORD}   timeout=10s
    Type Text  ${LOGIN_PASSWORD}  ${password}

Click Login Button
    Wait For Element To Be Visible   ${LOGIN_BUTTON}   timeout=10s
    Click  ${LOGIN_BUTTON}

Click Refresh Profile Button
    Wait For Element To Be Visible   ${REFRESH_PROFILE_BUTTON}   timeout=10s
    Click  ${REFRESH_PROFILE_BUTTON} 


Click LogOut Button
    Wait For Element To Be Visible   ${LOGOUT_BUTTON}   timeout=10s
    Click  ${LOGOUT_BUTTON} 