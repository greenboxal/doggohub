Feature: Project Bork
  Background:
    Given I sign in as a user
    And I am a member of project "Shop"
    When I visit project "Shop" page

  Scenario: User bork a project
    Given I click link "Bork"
    When I bork to my namespace
    Then I should see the borked project page

  Scenario: User already has borked the project
    Given I already have a project named "Shop" in my namespace
    And I click link "Bork"
    When I bork to my namespace
    Then I should see a "Name has already been taken" warning

  Scenario: Merge request on canonical repo goes to bork merge request page
    Given I click link "Bork"
    And I bork to my namespace
    Then I should see the borked project page
    When I visit project "Shop" page
    Then I should see "New merge request"
    And I goto the Merge Requests page
    Then I should see "New merge request"
    And I click link "New merge request"
    Then I should see the new merge request page for my namespace

  Scenario: Viewing borks of a Project
    Given I click link "Bork"
    When I bork to my namespace
    And I visit the borks page of the "Shop" project
    Then I should see my bork on the list

  Scenario: Viewing borks of a Project that has no repo
    Given I click link "Bork"
    When I bork to my namespace
    And I make borked repo invalid
    And I visit the borks page of the "Shop" project
    Then I should see my bork on the list

  Scenario: Viewing private borks of a Project
    Given There is an existent bork of the "Shop" project
    And I click link "Bork"
    When I bork to my namespace
    And I visit the borks page of the "Shop" project
    Then I should see my bork on the list
    And I should not see the other bork listed
    And I should see a private bork notice
