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
