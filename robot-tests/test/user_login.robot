*** Settings ***
Documentation  This test case is used to test User's login functionality
Resource         ../keywords/common.robot
Suite Setup      Launch training App
Suite Teardown   Close browser

*** Test cases ***

Verify successful user login
    [Documentation]   verify the User is able to log in succesfully
    Run Keyword And Ignore Error  Register New User    Bibi    12345
    Enter Login Username     Bibi  
    Enter Login Password     12345
    Click Login Button      
    Wait For Elements State  text=Login successful  visible  timeout=2s

Verify unsuccessful user login with an invalid password
    [Documentation]  verify the user is unable to log in with an invalid password
    Run Keyword And Ignore Error  Register New User    Efe    12345
    Enter Login Username            Efe
    Enter Login Password            Invalidpass1
    Click Login Button      
    Wait For Elements State         text=Login failed    visible  timeout=2s

Verify unsuccessful user login with non-existent user
    [Documentation]  verify the user is unable to log in as a non-existent user
    Enter Login Username         bibi   
    Enter Login Password         remote
    Click Login Button      
    Wait For Elements State         text=Login failed    visible  timeout=2s

Verify unsuccessful user login with empty fields
    [Documentation]  verify the user is unable to log in with empty fields
    Enter Login Username         
    Enter Login Password         
    Click Login Button      
    Wait For Elements State        text=Login failed    visible  timeout=2s

Verify session persistence after page refresh
    [Documentation]    verify the user remains logged in after refreshing the page
    Enter Login Username         Bibi
    Enter Login Password         12345
    Click Login Button      
    Wait For Elements State     text=Login successful  visible  timeout=2s
    Browser.Reload
    Wait For Elements State     text=Logged in    visible  timeout=2s
    