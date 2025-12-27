*** Settings ***
Documentation    This test case is used to test the profile management functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***

View Profile While Logged In
  [Documentation]  verify the User is able to log in succesful
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
