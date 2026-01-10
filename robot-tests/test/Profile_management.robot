*** Settings ***
Documentation    This test case is used to test the profile management functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***

View Profile While Logged In
  [Documentation]  verify the User is able to log in succesful
  Run Keyword And Ignore Error  Register New User    ruke    12345
  Enter Login Username    ruke
  Enter Login Password    12345
  Click Login Button
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Refresh Profile Button
  Get Text  //*[@id="profile_display"]  ==  👤 ruke\nLogged in

View Profile While Logged Out
  [Documentation]  verify the User is logout successful
  Click Logout Button
  Click Refresh Profile Button
  Get Text  //*[@id="me"]  ==  Not logged in

Profile Display Updates After Login
  [Documentation]  verify the User logged in successful
  Enter Login Username    ruke
  Enter Login Password    12345
  Click Login Button   
  Wait For Elements State  text=Login successful  visible  timeout=10s

Verify logged in user can access protected sites
  [Documentation]  verify the User can access protected sites after login
  Enter Login Username    werockglobal
  Enter Login Password    12345
  Click Login Button
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Open Protected Site Button
  Get Text  //*[@id="main-content"]/div/div[1]/h1  ==  Strategic\nService\nDelivery 

Verify logged out user cannot access protected sites
  [Documentation]  verify the User cannot access protected sites after logout
  Click Logout Protected Site Button
  Click Refresh Profile Button
  Get Text  //*[@id="me"]  ==  Not logged in
  Click Open Protected Site Button
  Get Text  //*[@id="notification"]  ==  You are not logged in. Please login first.
