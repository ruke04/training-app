*** Settings ***
Documentation    This test case is used to test the user registration functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Delete All Users From Database

*** Test Cases ***

Verify Successful User Registration
    [Documentation]    Verify the user was registered successfully
    ${rand}=        Generate Random String    6    [LETTERS]
    ${new_reg_user}=    Set Variable    newuser_${rand}
    Set Suite Variable    ${new_reg_user}
    Enter Username    ${new_reg_user}
    Enter Password    testpass123
    Click Sign Up Button
    Wait For Elements State  text=Registration successful! Please login to continue.  visible  timeout=2s

Verify Registration Failed With Existing Username
    [Documentation]    Verify the user was registered successfully
    Enter Username    ${new_reg_user}
    Enter Password    testpass123
    Click Sign Up Button
    Wait For Elements State  text=Registration failed: Username already exists    visible  timeout=2s
