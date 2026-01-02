*** Settings ***
Documentation  Verify company logo visibility
Resource         ../keywords/common.robot
Suite Setup      Launch training App
Suite Teardown   Close browser


*** Test Cases ***

Verify company logo is visible
    [Documentation]    This test is to verify that the company's logo is visible
    Wait For Element To Be Visible    ${TRAINING_APP_TITLE}

