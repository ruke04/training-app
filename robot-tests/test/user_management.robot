*** Settings ***
Documentation    This test case is used to test that user is logged in, user can list all users 
Library    Browser
Library    String
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser


*** Test Cases ***

Verify List Users While Logged In
    [Documentation]    Verify logged-in user can see users list
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
    Click Login Button
    Wait For Elements State    text=Login successful    visible    timeout=10s
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}   visible    timeout=10s

    # Verify column headers
    Wait For Elements State    role=columnheader[name="ID"]         visible
    Wait For Elements State    role=columnheader[name="Username"]   visible
    Wait For Elements State    role=columnheader[name="Created"]    visible

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
    # The current tab is the users list
    ${page_ids}=   Get Page Ids
    ${users_tab}=  Set Variable    ${page_ids}[0]
    Reload
    Wait For Element To Be Visible   ${TRAINING_APP_TITLE}   timeout=10s
    Enter Login Username  testuserw206
    Enter Login Password  testpass1205
    Click Login Button
    Wait For Elements State    text=Login successful    visible

    # Count the total rows on current user list table
    Click Show all user Button
    Wait For Elements State    ${USERS_LIST}    visible
    ${user_count}=    Get Element Count    ${TABLE_ROWS}  
    Log    ${user_count}

    # Open Incognito context for new user Registration
    New Context                 
    New Page                                ${APP_URL}   
    ${page_ids}=   Get Page Ids
    ${incognito_tab}=  Set Variable          ${page_ids}[-1]
    Switch Page    ${incognito_tab}
    Wait For Element To Be Visible           ${TRAINING_APP_TITLE}   timeout=10s
    
    # Define rand user name
    ${rand}=        Generate Random String    6    [LETTERS]
    ${new_user}=    Set Variable    newuser_${rand}
    Enter Username                             ${new_user}
    Enter Password    temu123
    Click Sign Up Button
    Wait For Elements State  text=Registration successful! Please login to continue.  visible  timeout=2s

    # Switch back to first session existing user
    Switch Page    ${users_tab}
    Reload
    Wait For Elements State    ${TRAINING_APP_TITLE}    visible    timeout=10s

    # Check that New user list table has more rows 
    Click Show all user Button
    ${New_User_count}=    Get Element Count    ${TABLE_ROWS}
    Log    ${New_User_count}
    Should Be True    ${New_User_count} > ${user_count}
    
    # Get the new user row to Verify it exsist
    Scroll To    ${USERS_LIST}
    Scroll To    ${LAST_ROW}
    Wait For Elements State    ${LAST_ROW}    visible
    ${last_row_text}=    Get Text    ${LAST_ROW}
    Log    Last row data: ${last_row_text}
   






