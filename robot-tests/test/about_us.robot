*** Settings ***
Documentation  Verify that About Us page loads and displays correct content
Resource         ../keywords/common.robot
Suite Setup      Launch training App
Suite Teardown   Close browser


*** Test Cases ***

Verify About Us Page Is Displayed
    [Documentation]    Verify that About Us page loads and displays correct content
    Run Keyword And Ignore Error  Register New User    Efe    12345
    Enter Login Username         Efe
    Enter Login Password         12345
    Click Login Button
    Wait For Elements State  text=Login successful  visible  timeout=2s
    Click Open Protected Site
    Click About us Button
    Wait For Elements State  text=About EFEWALICOMMS  visible  timeout=2s