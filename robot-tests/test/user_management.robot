*** Settings ***
Documentation    This test case is used to test that user is logged in, user can list all users 
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***

Verify List Users While Logged In
    [Documentation]    Verify logged-in user can see users list
    Run Keyword And Ignore Error  Register New User    testuserw206    testpass1205
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
    Click Login Button
    Wait For Elements State    text=Login successful    visible    timeout=10s
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}   visible    timeout=10s
    # Verify column headers
    Wait For Elements State    //*[text()="ID"]       visible
    Wait For Elements State    //*[text()="Username"]   visible
    Wait For Elements State    //*[text()="Created"]    visible
    # Verify users are displayed on the table
    ${user_count}=    Get Element Count    ${TABLE_ROWS}
    Log    User count in table: ${user_count}
    Should Be True    ${user_count} > 0
    # Scrollable check for users list
    Scroll To                  ${USERS_LIST} 
    Scroll To                  ${LAST_ROW}
    Wait For Elements State    ${LAST_ROW}      visible
    
   
Verify List Users While Logged Out
    [Documentation]    Verify error is shown when listing users without login
    Click Logout Button
    Click Show all user Button
    Wait For Elements State    ${NOTIFICATION_MESSAGE}    visible
    ${notification_text}=    Get Text    ${NOTIFICATION_MESSAGE}
    Log    Notification text: ${notification_text}
    Should Be Equal As Strings    ${notification_text}    You are not logged in.

Verify Users List Shows Newly Registered User
    [Documentation]    Verify newly registered user appears in users list
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
    Click Login Button
    Wait For Elements State    text=Login successful    visible
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}    visible
    ${user_count}=    Get Element Count    ${TABLE_ROWS}  
    Log    ${user_count}
    # Define rand user name
    ${rand}=        Generate Random String    6    [LETTERS]
    ${new_user}=    Set Variable    newuser_${rand}
    Run Keyword And Ignore Error  Register New User    ${new_user}    temu123
    Reload
    Sleep    2s
    # Check that New user list table has more rows 
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}    visible
    ${New_User_count}=    Get Element Count    ${TABLE_ROWS}
    Log    ${New_User_count}
    Should Be True    ${New_User_count} > ${user_count}
    # Get the new user row to Verify it exsist
    Scroll To    ${USERS_LIST}
    Scroll To    ${LAST_ROW}
    Wait For Elements State    ${LAST_ROW}    visible
    ${last_row_text}=    Get Text    ${LAST_ROW}
    Log    Last row data: ${last_row_text}
   
Verify User Can Be Deleted 
    [Documentation]    Verify user can be deleted in users list 
    ${new_user} =  Get Text    ${LAST_ROW}/td[2]        #takes the username from the last column
    Enter username to delete    ${new_user}
    Click Delete User Button
    Wait For Elements State    ${NOTIFICATION_MESSAGE}    visible   timeout=10s
    FOR    ${i}    IN RANGE    10
        ${notification_text}=    Get Text    ${NOTIFICATION_MESSAGE}
        ${notification_text}=    Strip String    ${notification_text}
        Run Keyword If    "${notification_text}" != ""    Exit For Loop
        Sleep    1s
    END
    Log    Notification text: ${notification_text}
    Should Not Be Empty    ${notification_text}
    Should Contain    ${notification_text}    deleted successfully


    

