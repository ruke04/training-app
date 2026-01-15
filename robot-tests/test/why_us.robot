*** Settings ***
Documentation    This test case is used to test the profile management functionality
Resource         ../keywords/common.robot
Suite Setup       Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***

View Profile While Logged In
  [Documentation]  verify the User is able to log succesfully
  Enter Login Username    werockglobal
  Enter Login Password    12345
  Click Login Button
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Refresh Profile Button
  Get Text  //*[@id="profile_display"]  ==  👤 werockglobal\nLogged in

Verify logged in user can access Why Us page
  [Documentation]  verify the User can access protected sites after login
  Enter Login Username    werockglobal
  Enter Login Password    12345
  Click Login Button
  Wait For Elements State  text=Login successful  visible  timeout=10s
  Click Open Protected Site Button
  Get Text  //*[@id="main-content"]/div/div[1]/h1  ==  Strategic\nService\nDelivery 
  Click Why Us Button
  Get Text  //*[@id="hero-heading"]  ==  Why Choose EFEWALICOMMS