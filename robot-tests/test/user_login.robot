*** Settings ***
Documentation  This test case is used to test User's login functionality
Resource         ../keywords/common.robot
Suite Setup      Launch training App
Suite Teardown   Close browser


*** Test cases ***
verify suceessful user login
    [Documentation]   verify the User is able to log in succesfully
    Enter Login Username  Bibi  
    Enter Login Password  12345
    Click Login Button      
    Wait For Elements State  text=Login successful  visible  timeout=2s
