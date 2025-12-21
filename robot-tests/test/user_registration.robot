*** Settings ***
Documentation    This test case is used to test the user registration functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser


*** Test Cases ***

Verify Successful User Registration
    [Documentation]    Verify the user was registered successfully
    Enter Username    testuserww
    Enter Password    testpass123
    Click Sign Up Button
    Wait For Elements State  text=Registration successful! Please login to continue.  visible  timeout=2s

Verify Registration Failed With Existing Username
    [Documentation]    Verify the user was registered successfully
    Enter Username    testuserww
    Enter Password    testpass123
    Click Sign Up Button
    Wait For Elements State  text=Registration failed: Username already exists    visible  timeout=2s
