*** Settings ***
Documentation  Verify company logo visibility
Resource         ../keywords/common.robot
Suite Setup      Launch training App
Suite Teardown   Close browser


*** Test Cases ***

Verify company logo is visible
    [Documentation]    This test is to verify that the company's logo is visible
    Run Keyword And Ignore Error  Register New User    Efe    12345
    Enter Login Username         Efe
    Enter Login Password         12345
    Click Login Button      
    Wait For Elements State  text=Login successful  visible  timeout=2s
    Click Open Protected Site
    Wait For Element To Be Visible   ${COMPANY_LOGO}    timeout=10s

