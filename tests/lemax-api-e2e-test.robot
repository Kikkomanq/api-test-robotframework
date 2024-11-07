*** Settings ***
Resource        ../keywords/keywords.robot

Suite Setup     Initialize Authorization Process


*** Test Cases ***
Scenario 1: Verify /tours endpoint is returning correct status code
    Given User gets tours details from /tours endpoint
    Then Response is with expected value

Scenario 2: Retrieve details and optional services of first selected tour
    Given User gets tours details from /tours endpoint
    When I get the tour ID and Option ID
    And I send tour ID and Option ID
    Then ShoppingCartReference is generated

Scenario 3: Verify that cart reference id is generated
    Given ShoppingCartReference is present as test data
    When I send booking refereference to cart endpoint
    Then Id with booking cart will be generated

Scenario 4: Verify that reservation can be done with valid booking reference
    Given ShoppingCartReference is present as test data
    And I send booking refereference to cart endpoint
    When I send cart Id to reserve endpoint
    Then Selected Tour should be reserved with code "RESERVED"

Scenario 5: Verify that booking can be done with valid booking reference and valid payload
    Given ShoppingCartReference is present as test data
    And I send booking refereference to cart endpoint
    And I send cart Id to reserve endpoint
    When I send valid payload so to make booking
    Then A unique booking identifier is returned that can be used for further booking amends

Scenario 6: Verify that booking endpoint can be generated and proper startus code is returned
    Given ShoppingCartReference is present as test data
    And I send booking refereference to cart endpoint
    And I send cart Id to reserve endpoint
    When I send valid payload so to make booking
    Then A unique booking identifier is returned that can be used for further booking amends
    And A booking endpoint returnes valid status code









