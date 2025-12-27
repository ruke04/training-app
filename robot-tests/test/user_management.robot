*** Settings ***
Documentation    This test case is used to test that user is logged in, user can list all users 
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***

Verify List Users While Logged In
    [Documentation]    Verify logged-in user can see users list
<<<<<<< HEAD
    Run Keyword And Ignore Error  Register New User    testuserw206    testpass1205
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
=======
    Enter Login Username  testuserww
    Enter Login Password  testpass123
>>>>>>> cc41d91 (Add robot test updates and Dockerfile)
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
<<<<<<< HEAD
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
=======
    # The current tab is the users list
    ${page_ids}=   Get Page Ids
    ${users_tab}=  Set Variable    ${page_ids}[0]
    Reload
    Wait For Element To Be Visible   ${TRAINING_APP_TITLE}   timeout=10s
    Enter Login Username  testuserww
    Enter Login Password  testpass123
>>>>>>> cc41d91 (Add robot test updates and Dockerfile)
    Click Login Button
    Wait For Elements State    text=Login successful    visible
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}    visible
    ${user_count}=    Get Element Count    ${TABLE_ROWS}  
    Log    ${user_count}
    # Define rand user name
    ${rand}=        Generate Random String    6    [LETTERS]
    ${new_user}=    Set Variable    newuser_${rand}
    Enter Username    ${new_user}
    Enter Password    temu123
    Click Sign Up Button
    Wait For Elements State  text=Registration successful! Please login to continue.  visible  timeout=2s
    # Check that New user list table has more rows 
    Click Show all user Button
<<<<<<< HEAD
    Sleep    2s
=======
    Wait For Elements State    ${USERS_LIST}    visible
>>>>>>> cc41d91 (Add robot test updates and Dockerfile)
    ${New_User_count}=    Get Element Count    ${TABLE_ROWS}
    Log    ${New_User_count}
    Should Be True    ${New_User_count} > ${user_count}
    # Get the new user row to Verify it exsist
    Scroll To    ${USERS_LIST}
    Scroll To    ${LAST_ROW}
    Wait For Elements State    ${LAST_ROW}    visible
    ${last_row_text}=    Get Text    ${LAST_ROW}
    Log    Last row data: ${last_row_text}
   






