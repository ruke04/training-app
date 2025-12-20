*** Settings ***
Documentation    This test case is used to test the profile management functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***
View Profile While Logged In
  [Documentation]  verify the User is able to log in succesful
  Enter Login Username    werockglobal
  Enter Login Password    12345
  Click Login Button
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Refresh Profile Button
View Profile While Logged Out
  [Documentation]  verify the User is logout successful
  Click LogOut Button
  Click Refresh Profile Button
  Wait For Elements State  text=Login successful  visible  
  Click Refresh Profile Button
  Sleep    5s

Profile Display Updates After Login
  [Documentation]  verify the User logged in successful
  Enter Login Username    werockglobal
  Enter Login Password    12345
  Click Login Button   
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Refresh Profile Button
  Sleep    5s
      
*** Keywords ***

*** Keywords ***

*** Variables ***