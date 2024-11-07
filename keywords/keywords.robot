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
${booking_id}


*** Keywords ***
#Suite Setup
Initialize Authorization Process
    # Obtain bearer token
    ${token}    ${base_url}=    Get Bearer Token
    Set Suite Variable    ${TOKEN}    ${token}
    Set Suite Variable    ${BASE_URL}    ${base_url}
    Log    Bearer Token obtained.
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
    Should Be Equal As Strings    France Highlights Tour    ${value}[0]
    ${value}=    Get Value From Json    ${response.json()}    $.tours[0].code
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

I send booking refereference to cart endpoint
    ${response}=    POST On Session
    ...    api_session
    ...    /v1/carts
    ...    json=${json_content}
    Should Be Equal As Integers    ${response.status_code}    201
    ${cartId}=    Get Value From Json
    ...    ${response.json()}
    ...    $.id
    ${cartId}=    Get From List    ${cartId}    0
    Set Test Variable    ${cartId}
    RETURN    ${cartId}

Id with booking cart will be generated
    Should Not Be Empty    ${cartId}
    Log  ${cartId}

I send cart Id to reserve endpoint
    ${response}=    POST On Session
    ...    api_session
    ...    /v1/carts/${cart_id}/reserve
    Should Be Equal As Integers    ${response.status_code}    200
    Set Test Variable  ${response}

Selected Tour should be reserved with code "RESERVED"
    Log To Console  ${response.json()} 
    ${booking_code}=    Get Value From Json    ${response.json()}   $.items[0].status.code
    Log To Console  ${booking_code}
    Set Test Variable    ${booking_code}
    ${booking_code}=    Get From List    ${booking_code}    0
    Should Be Equal As Strings    ${booking_code}   RESERVED

I send valid payload so to make booking
    # Generate a random 23-digit externalIdentifier
    ${externalIdentifier}=    Evaluate    ''.join(random.choices(string.digits, k=23))    modules=random,string

    # Build address dictionary
    ${address}=    Create Dictionary
    ...    countryCode=US
    ...    state=California
    ...    city=Malibu
    ...    streetName=Malibu Point
    ...    streetNumber=10880
    ...    postalCode=90265

    # Build customer dictionary
    ${customer}=    Create Dictionary
    ...    title=Mr.
    ...    firstName=Tony
    ...    lastName=Stark
    ...    middleName=Edward
    ...    email=tony.stark@starkindustries.com
    ...    contactNumber=+1 (555) 987-6543
    ...    address=${address}

    # Build price dictionary
    ${price}=    Create Dictionary
    ...    amount=153.4
    ...    currencyCode=USD

    # Build payment dictionary
    ${payment}=    Create Dictionary
    ...    price=${price}
    ...    formOfPayment=Credit card
    ...    externalIdentifier=${externalIdentifier}

    # Build additionalInformation dictionary
    ${additionalInformation}=    Create Dictionary
    ...    customInfoParameter1=custom value 1
    ...    customInfoParameter2=custom value 2
    ...    customInfoParameter3=custom value 3

    # Build the main payload dictionary
    ${payload}=    Create Dictionary
    ...    customer=${customer}
    ...    payment=${payment}
    ...    note=Very special booking requirements
    ...    status=Confirmed
    ...    additionalInformation=${additionalInformation}

    # Log the payload for debugging
    Log To Console    ${payload}

    # Use the payload in a POST request
    ${response}=    POST On Session    api_session    /v1/carts/${cart_id}/book    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    201
    Log To Console    ${response.json()}
    Set Test Variable  ${response}

A unique booking identifier is returned that can be used for further booking amends
    # TODO: implement keyword "A unique booking identifier is returned that can be used for further booking amends".
    ${booking_id}=    Get Value From Json    ${response.json()}   $.bookingId
    ${booking_id}=    Get From List    ${booking_id}    0
    Set Test Variable  ${booking_id}
    Log To Console  ${booking_id}


A booking endpoint returnes valid status code
    ${response}=    GET On Session   api_session    /v1/bookings/${booking_id}
    Should Be Equal As Integers    ${response.status_code}    200
  