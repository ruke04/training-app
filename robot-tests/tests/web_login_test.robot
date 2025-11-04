
*** Settings ***
Library    Browser
Library    String

*** Variables ***

${HEADLESS}   False

*** Test Cases ***
Register And Login UI Test
    New Browser    chromium    headless=${HEADLESS}
    New Page    http://localhost:8080
    Set Browser Timeout    20s
    ${suffix}=    Generate Random String    6    [LOWER]
    ${user}=    Set Variable    student-${suffix}
    ${pwd}=     Set Variable    12345

    # Register
    Fill Text    id=reg_username    ${user}
    Fill Text    id=reg_password    ${pwd}
    Click    text=Sign Up
    Wait For Elements State    text=Registration successful    visible

    # Login
    Fill Text    id=username    ${user}
    Fill Text    id=password    ${pwd}
    Click    text=Login
    Wait For Elements State    text=Login successful    visible

    # Fetch Me
    Click    text=Fetch Me
    Wait For Elements State    css=pre#me >> text=${user}    visible
    Close Browser
