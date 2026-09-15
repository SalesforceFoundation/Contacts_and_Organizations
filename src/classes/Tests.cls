/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class Tests {

    static testMethod void TestConstants() {
    	system.assertNotEquals(NULL, Constants.getContactsSettings());
        system.assertNotEquals(NULL, Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c()));
        Constants.isOneToOne();
        Constants.GetIndividualAccountId();
        Constants.setIndividualAccountForTests('foo are you');        
    }
    
    static testMethod void TestIndividualAccounts() {
    	system.assertEquals(0, IndividualAccounts.getContactDonationHistory(null));
        try {
            IndividualAccounts.getContactLastDonation(null);
            system.assert(false, 'getContactLastDonation is disabled and must always throw');
        } catch (System.NoAccessException e) {
            // expected: method is stubbed to refuse all callers
        }
    }

    // getContactDonationHistory must not disclose Opportunity.Amount to a caller
    // without FLS read access to that field.
    static testMethod void TestIndividualAccountsEnforcesFLS() {
        // Setup-object DML (User, PermissionSetAssignment) and non-setup-object DML
        // (Contact, Opportunity) cannot mix in one transaction. Isolating the setup-object
        // DML inside its own System.runAs boundary (even as the current user) avoids
        // MIXED_DML_OPERATION when this test method also inserts Contact/Opportunity records.
        Profile restrictedProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'];
        User restrictedUser = new User(
            ProfileId = restrictedProfile.Id,
            LastName = 'Restricted',
            FirstName = 'FLS',
            Email = 'fls.test.user@example.com',
            Username = 'fls.test.user' + DateTime.now().getTime() + '@example.com',
            Alias = 'flstst',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert restrictedUser;

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FLS_Test_No_Opportunity_Amount'];
            insert new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = ps.Id);
        }

        Contact c = new Contact(LastName = 'FLSTest');
        insert c;

        Opportunity o = new Opportunity(
            Name = 'FLS Test Opp',
            AccountId = [SELECT AccountId FROM Contact WHERE Id = :c.Id].AccountId,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 100
        );
        insert o;
        insert new OpportunityContactRole(ContactId = c.Id, OpportunityId = o.Id);

        System.runAs(restrictedUser) {
            Boolean blockedDonationHistory = false;
            try {
                IndividualAccounts.getContactDonationHistory(c.Id);
            } catch (System.QueryException qe) {
                blockedDonationHistory = true;
            }
            system.assert(blockedDonationHistory, 'Expected getContactDonationHistory to enforce FLS and block a user without read access to Opportunity.Amount');
        }
    }

}