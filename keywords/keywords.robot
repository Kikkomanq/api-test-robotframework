*** Settings ***
Library     ${CURDIR}/../utils/TokenLibrary.py
Library     OperatingSystem
Library     RequestsLibrary
Library     JSONLibrary
Library     Collections


*** Variables ***
${BASE_URL}
${base_url}
${response}
${tour_id}
${options_id}
${shoppingCartReference}
${json_content}
${cartId}


*** Keywords ***
#Suite Setup
Initialize Authorization Process
    # Obtain bearer token
    ${token}    ${base_url}=    Get Bearer Token
    Set Suite Variable    ${TOKEN}    ${token}
    Set Suite Variable    ${BASE_URL}    ${base_url}
    Log    Bearer Token obtained.
    Log To Console    ${BASE_URL}
    # Set up headers
    ${HEADERS}=    Create Dictionary
    ...    Authorization=Bearer ${TOKEN}
    ...    Content-Type=application/json
    Log    Headers set: ${HEADERS}
    # Create API session
    Create Session    api_session    ${BASE_URL}    headers=${HEADERS}

User gets tours details from /tours endpoint
    ${response}=    GET On Session    api_session    /v1/tours
    Should Be Equal As Integers    ${response.status_code}    200
    Set Test Variable    ${response}
    Log    Response: ${response.text}

Response is with expected value
    ${value}=    Get Value From Json    ${response.json()}    $.tours[0].name
    Log To Console    Tour Name: ${value}
    Should Be Equal As Strings    France Highlights Tour    ${value}[0]
    ${value}=    Get Value From Json    ${response.json()}    $.tours[0].code
    Log To Console    Tour Code: ${value}
    Should Be Equal As Strings    FR-3456    ${value}[0]

I get the tour ID and Option ID
    [Documentation]    Makes a GET request to the tours endpoint and verifies the response
    ${response}=    GET On Session    api_session    /v1/tours
    Should Be Equal As Integers    ${response.status_code}    200
    ${tour_id}=    Get Value From Json    ${response.json()}    $.tours[0].id
    ${tour_id}=    Get From List    ${tour_id}    0
    ${options_id}=    Get Value From Json    ${response.json()}    $.tours[0].options[0].id
    ${options_id}=    Get From List    ${options_id}    0
    ${shoppingCartReference}=    Get Value From Json
    ...    ${response.json()}
    ...    $.tours[0].options[0].departures[0].shoppingCartReference
    ${shoppingCartReference}=    Get From List    ${shoppingCartReference}    0
    Set Test Variable    ${tour_id}
    Set Test Variable    ${options_id}
    Set Test Variable    ${shoppingCartReference}
    Log To Console    ${tour_id}
    Log To Console    ${options_id}
    Log To Console    ${shoppingCartReference}

I send tour ID and Option ID
    ${response}=    GET On Session    api_session    /v1/tours/${tour_id}/options/${options_id}
    Should Be Equal As Integers    ${response.status_code}    200

ShoppingCartReference is generated
    Should Not Be Empty    ${shoppingCartReference}
    RETURN    ${shoppingCartReference}

ShoppingCartReference is present as test data
    ${json_path}=    Join Path    ${CURDIR}    ../data/cartReference.json
    ${json_content}=    Load Json From File    ${json_path}
    # ${cartReference}=    Get Value From Json    ${json_content}    $.items[0].reference
    Set Test Variable    ${json_content}

    Log To Console    ${json_content}

I send booking refereference to cart endpoint
    ${response}=    POST On Session
    ...    api_session
    ...    /v1/carts
    ...    json=${json_content}
    Should Be Equal As Integers    ${response.status_code}    201
    ${cartId}=    Get Value From Json
    ...    ${response.json()}
    ...    $.id
    Set Test Variable    ${cartId}
    RETURN    ${cartId}

Id with booking cart will be generated
    Should Not Be Empty    ${cartId}
    Log  ${cartId}
