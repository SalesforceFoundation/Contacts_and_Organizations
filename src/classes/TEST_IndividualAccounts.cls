/*
    Copyright (c) 2011, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.com Foundation
* @date 2011 (1.x)
* @description Tests for IndividualAccounts
*/
@isTest
private class TEST_IndividualAccounts {    
/* TESTING CONTACT AND ACCOUNT PLUMBING ------------------------------------------------*/

    /// <name> IndividualAccounts </name>
    /// <summary> test default constructor </summary>
    static testMethod void IndividualAccounts() {
        IndividualAccounts testIndividualAccounts = new IndividualAccounts();
    }

    /// <name> insertPrivate </name>
    /// <summary> Test Method for inserting a Contact that should get no account </summary>
    static testMethod void insertPrivate()
    {
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            Private__c=true,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS, 
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        
        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
    
    }
    
    static testMethod void insertOneToOneChangeToPrivate()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        
        insertedContacts[0].Private__c = true;
        update insertedContacts;
        insertedContacts = [Select FirstName, LastName, AccountId,Private__c  from Contact where id=:con.id];
        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
        system.assert(insertedContacts[0].Private__c);
    
    }
    
    static testMethod void insertOneToOneTriggerOff()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR,Disable_Account_Model_Trigger__c=true));
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];

        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[0].AccountId);
    
    }

    /// <name> insertUpdateOneToOne </name>
    /// <summary> Test Method for inserting and updating a Contact in the One-to-One model</summary>
    static testMethod void insertUpdateOneToOne()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, Account.Name,Account.One2OneContact__c,MailingStreet,Account.BillingStreet,Organization_Type__c,Account.SYSTEMIsIndividual__c  from Contact where id=:con.id];
        system.debug(insertedContacts);
        system.debug(insertedcontacts[0].id);
        system.debug(insertedContacts);
        //one contact should have been created
        system.assertEquals(1,insertedContacts.size());
        //the account should have the right type
        system.assertEquals(Constants.ONE_TO_ONE_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should be flagged as an individual
        system.assertEquals(true,insertedcontacts[0].Account.SYSTEMIsIndividual__c );
        //the account should have been named correctly
        system.assertEquals(Constants.CONTACT_FIRSTNAME_FOR_TESTS + ' ' + Constants.CONTACT_LASTNAME_FOR_TESTS,insertedcontacts[0].Account.Name);
        //relationship should be bi-directional
        system.assertEquals(insertedcontacts[0].id,insertedcontacts[0].Account.One2OneContact__c);
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,insertedcontacts[0].Account.BillingStreet);
        system.assertEquals(insertedcontacts[0].MailingStreet,insertedcontacts[0].Account.BillingStreet);
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        con.LastName=updatedContactLastName;
        con.OtherCity = updatedOtherCity;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, Account.Name,Account.One2OneContact__c,MailingStreet,OtherCity,Account.BillingStreet,Account.ShippingCity from Contact where id=:con.id];
        
        //the account should have been named correctly
        system.assertEquals(updatedContacts[0].firstName + ' ' + updatedContacts[0].LastName,updatedContacts[0].Account.Name);
        //relationship should be bi-directional
        system.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.One2OneContact__c);
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,updatedContacts[0].MailingStreet);
        system.assertEquals(updatedOtherCity,updatedContacts[0].Account.ShippingCity);
        system.assertEquals(updatedContacts[0].MailingStreet,updatedContacts[0].Account.BillingStreet);
        system.assertEquals(updatedContacts[0].OtherCity,updatedContacts[0].Account.ShippingCity);
        
    }
    /*
    static testMethod void testDefault()
    {
       
        boolean aDefaultIsSelected = false;
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.Salutation;
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            for(Schema.PicklistEntry pe : P){
            	system.debug(pe.getValue() + ' : ' + pe.isDefaultValue());
                if (pe.isDefaultValue()){
                        aDefaultIsSelected = true;
                }
            }
         system.assert(aDefaultIsSelected); 
    }
    */
    
    /// <name> detachOneToOne </name>
    /// <summary> Test Method for separating a Contact from it's One-to-One account</summary>
    static testMethod void detachOneToOne()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id=:con.id];      
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        
        con.AccountId = null;
        con.LastName = updatedContactLastName;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.One2OneContact__c from Contact where id=:con.id];
        
        //Original Account should still be there
        Account[] originalAccount = [Select id from Account where Id=:originalAccountId];
        
        system.assertEquals(1,originalAccount.size());
        
        //AccountId of updated contact should match the orignial Account
        system.assertEquals(originalAccountId,updatedContacts[0].AccountId);
    
    }
        
    /// <name> editContactDuringDetachOneToOne </name>
    /// <summary> Test Method for editing a contact while it is being detached from it's One-to-One Account. This was a bug (#37)</summary>
    static testMethod void editContactDuringDetachOneToOne()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
                
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id=:con.id];      
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updateContactMailingStreet = '234 Oak St';
        
        con.AccountId = null;
        con.LastName = updatedContactLastName;
        con.MailingStreet = updateContactMailingStreet;
        update con;
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.One2OneContact__c,MailingStreet,Organization_Type__c,Account.BillingStreet from Contact where id=:con.id];
        
        //AccountId of updated contact should match the orignial Account
        system.assertEquals(originalAccountId,updatedContacts[0].AccountId);
        
        //org type should be set correctly
        system.assertEquals(Constants.ONE_TO_ONE_ORGANIZATION_TYPE,updatedContacts[0].Organization_Type__c);
        
        //the account should have been named correctly
        system.assertEquals(updatedContacts[0].FirstName + ' ' + updatedContacts[0].LastName,updatedContacts[0].Account.Name);
        
        //addresses should be sync'd
        system.assertEquals(updateContactMailingStreet,updatedContacts[0].MailingStreet);
        system.assertEquals(updatedContacts[0].MailingStreet,updatedContacts[0].Account.BillingStreet);
        
    }

    /// <name> attachToIndividualAccount </name>
    /// <summary> Test Method for a new Contact in the Bucket Individual model </summary>
    static testMethod void attachToIndividualAccount()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        //the contact should have the right type
        system.assertEquals(Constants.BUCKET_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should have been named correctly
        system.assertEquals(Constants.BUCKET_ACCOUNT_NAME,insertedcontacts[0].Account.Name);
        
    }
    
    /// <name> detachIndividualAccount </name>
    /// <summary> Test Method for detaching a Contact from the bucket individual account </summary>
    static testMethod void detachIndividualAccount()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        Id AccountId = insertedContacts[0].AccountId;
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should have the right type
        system.assertEquals(Constants.BUCKET_ORGANIZATION_TYPE,updatedContacts[0].Organization_Type__c);
        //the account should have been named correctly
        system.assertEquals(Constants.BUCKET_ACCOUNT_NAME,updatedContacts[0].Account.Name);
        //the account should have the correct AccountId
        system.assertEquals(AccountId,updatedContacts[0].AccountId);        
        
    }

    /// <name> detachFromNormalAccountToBucket </name>
    /// <summary> Test Method for detaching a Contact from a normal account. It should land in the bucket account. </summary>
    static testMethod void detachFromNormalAccountToBucket()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account acct = new Account(Name='Test Account 876');
        insert acct;
        
        Account[] insertedAccount = [select SystemIsIndividual__c from Account where id = :acct.id];
        
        //the account should not be an individual one
        system.assert(!insertedAccount[0].SystemIsIndividual__c);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	AccountId = acct.id,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        //the account should not be an individual account
        system.assert(!insertedContacts[0].Account.SystemIsIndividual__c);
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        //the account should be an individual account
        system.assert(updatedContacts[0].Account.SystemIsIndividual__c);
        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);  
              
        
    }
    
    static testMethod void contactAddedToExistingOneToOne()
    {
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        Id accountId = insertedContacts[0].AccountId;
        
        Contact con2 = new Contact(FirstName='John', LastName='Smith',AccountId=accountId);
        
        insert con2;
        
        Contact[] insertedContact = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con2.id];
        
        system.assertNotEquals(accountId,insertedContact[0].AccountId);  
              
        
    }
    
    static testMethod void contactInNormalOrgNameChange()
    {
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        String acctName = 'Test Account 876';
        Account acct = new Account(Name=acctName);
        insert acct;

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	AccountId = acct.id,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        
        system.assertEquals(acctName,insertedContacts[0].Account.Name);
        
        
        Contact con2 = new Contact(id=con.id, LastName='Smith');
        
        update con2;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        system.assertEquals(acctName,updatedContacts[0].Account.Name);  
              
        
    }
    
    
    /// <name> detachFromNormalAccountToOneToOne </name>
    /// <summary> Test Method for detaching a Contact from a normal account. It should land in a one-to-one account. </summary>
    static testMethod void detachFromNormalAccountToOneToOne()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account acct = new Account(Name='Test Account 876');
        insert acct;
        
        Account[] insertedAccount = [select SystemIsIndividual__c from Account where id = :acct.id];
        
        //the account should not be an individual one
        system.assert(!insertedAccount[0].SystemIsIndividual__c);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	AccountId = acct.id,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select Account.Name,Account.SystemIsIndividual__c,AccountId,Organization_Type__c from Contact where id=:con.id];
        
        //the contact should be connected to the account
        system.assertEquals(acct.id,insertedContacts[0].AccountId);
        //the account should not be an individual account
        system.assert(!insertedContacts[0].Account.SystemIsIndividual__c);
             
        con.AccountId = null;
        update con;
        
        Contact[] updatedContacts = [Select Account.Name,AccountId,Account.SystemIsIndividual__c,Organization_Type__c from Contact where id=:con.id];
        
        //the account should be an individual account
        system.assert(updatedContacts[0].Account.SystemIsIndividual__c);
        //the account should not be the one we started with
        system.assertNotEquals(acct.id,updatedContacts[0].AccountId);  
              
        
    }
    
     public static testMethod void deleteContactNoOpp() {

        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));

        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Id contactId;
        contactId = con.id;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        Id createdAccountId = insertedContacts[0].AccountId;
        
        delete con;
        
        insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        system.assertEquals(0,insertedContacts.size());
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(0,missingAccount.size());


    }
    public static testMethod void deleteContactWithOpp() {
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Id contactId;
        contactId = con.id;
        Id accountId;
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:contactId];
        
        Id createdAccountId = insertedContacts[0].AccountId;
       
       Opportunity opp = new Opportunity(
            Amount=500,
            AccountId=createdAccountId,
            Name='test',
            StageName='Closed/Won',
            CloseDate=System.today()
        );
        insert opp;
        
        delete con;
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());

    }
    
    public static testMethod void deleteContactNormalAccount() {
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Account orgAccount = new Account(
            Name='Fake account'
        );
        insert orgAccount;
        
        
        
        String newContactMailingStreet = '123 Elm St';

        Contact con = new Contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
            MailingStreet = newContactMailingStreet,
            AccountId=orgAccount.id,
            WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id=:con.id];
        
        Id createdAccountId = insertedContacts[0].AccountId;
            
        delete con;
        
        Account[] missingAccount = [select id from Account where id=:createdAccountId];
        system.assertEquals(1,missingAccount.size());

    }
    
/* TESTING PHONE NUMBER WORKFLOW -------------------------------------------------------
 
    /// <name> createContactWithPhoneNoPref </name>
    /// <summary> Test Method for creating a contact with a phone number and no preferences set. </summary>
    static testMethod void createContactWithPhoneNoPref()
    {
        //with no other prefs, phone should land in workphone__c and set PreferredPhone__c to 'work'.
        String newPhone = '206-777-7777';
        String preferredPhone = null;
        String workPhoneString = 'Work';
        Contact con = new Contact(FirstName='test', LastName='contact678',phone=newPhone,PreferredPhone__c=preferredPhone);
        insert con;
        
        Contact[] insertedContacts = [Select phone,workPhone__c,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(newPhone,insertedContacts[0].Phone);
        system.assertEquals(newPhone,insertedContacts[0].WorkPhone__c);
        system.assertEquals(workPhoneString,insertedContacts[0].PreferredPhone__c);
        
    }
    
    /// <name> createContactWithPhoneNoPrefAlsoHomePhone </name>
    /// <summary> Test Method for creating a contact with a phone number and a home number. </summary>
    static testMethod void createContactWithPhoneNoPrefAlsoHomePhone()
    {
        //with pref set to Home, HomePhone should land in Phone and set PreferredPhone__c to 'home'.
        //currently HomePhone data is lost.
        String newPhone = '206-777-7777';
        String newHomePhone = '888-898-9999';
        String preferredPhone = 'Home';
        Contact con = new Contact(FirstName='test', LastName='contact678',phone=newPhone,HomePhone=newHomePhone,PreferredPhone__c=preferredPhone);
        insert con;
        
        Contact[] insertedContacts = [Select phone,workPhone__c,HomePhone,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(newPhone,insertedContacts[0].Phone);
        system.assertEquals(newPhone,insertedContacts[0].HomePhone);
        system.assertEquals(null,insertedContacts[0].WorkPhone__c);
        system.assertEquals(preferredPhone,insertedContacts[0].PreferredPhone__c);
        
    }
    
    /// <name> createContactWithPhonePrefSet </name>
    /// <summary> Test Method for creating a contact with a phone number in Phone and the preferred phone set. </summary>
    static testMethod void createContactWithPhonePrefSet()
    {
        //with pref set to Home, HomePhone should land in Phone and set PreferredPhone__c to 'home'.
        //these are currently commented out because it's not supported. See #47.
        String newPhone = '206-777-7777';
        String preferredPhone = 'Home';
        Contact con = new Contact(FirstName='test', LastName='contact678',phone=newPhone,PreferredPhone__c=preferredPhone);
        insert con;
        
        Contact[] insertedContacts = [Select phone,HomePhone,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(newPhone,insertedContacts[0].Phone);
        system.assertEquals(newPhone,insertedContacts[0].HomePhone);
        system.assertEquals(preferredPhone,insertedContacts[0].PreferredPhone__c);
        
        //test work phone
        preferredPhone = 'Work';
        
        Contact con1 = new Contact(FirstName='test', LastName='contact678',phone=newPhone,PreferredPhone__c=preferredPhone);
        insert con1;
        
        Contact[] insertedContacts1 = [Select phone,WorkPhone__c,PreferredPhone__c from Contact where id=:con1.id];
        
        system.assertEquals(newPhone,insertedContacts1[0].Phone);
        system.assertEquals(newPhone,insertedContacts1[0].WorkPhone__c);
        system.assertEquals(preferredPhone,insertedContacts1[0].PreferredPhone__c);
        
        //test mobile phone
        preferredPhone = 'Mobile';
        
        Contact con2 = new Contact(FirstName='test', LastName='contact678',phone=newPhone,PreferredPhone__c=preferredPhone);
        insert con2;
        
        Contact[] insertedContacts2 = [Select phone,MobilePhone,PreferredPhone__c from Contact where id=:con2.id];
        
        system.assertEquals(newPhone,insertedContacts2[0].Phone);
        system.assertEquals(newPhone,insertedContacts2[0].MobilePhone);
        system.assertEquals(preferredPhone,insertedContacts2[0].PreferredPhone__c);
        
        //test other phone
        preferredPhone = 'Other';
        
        Contact con3 = new Contact(FirstName='test', LastName='contact678',phone=newPhone,PreferredPhone__c=preferredPhone);
        insert con3;
        
        Contact[] insertedContacts3 = [Select phone,OtherPhone,PreferredPhone__c from Contact where id=:con3.id];
        
        system.assertEquals(newPhone,insertedContacts3[0].Phone);
        system.assertEquals(newPhone,insertedContacts3[0].OtherPhone);
        system.assertEquals(preferredPhone,insertedContacts3[0].PreferredPhone__c);
        
    }
    
    /// <name> createContactWithNumberAndPrefSet </name>
    /// <summary> Test Method for creating a contact with a phone number in the correct field
    /// and the preferred phone set. </summary>
    static testMethod void createContactWithNumberAndPrefSet()
    {
        //with pref set to Home, HomePhone should land in Phone and set PreferredPhone__c to 'home'.
        //these are currently commented out because it's not supported. See #47.
        String newPhone = '206-777-7777';
        String preferredPhone = 'Home';
        Contact con = new Contact(FirstName='test', LastName='contact678',HomePhone=newPhone,PreferredPhone__c=preferredPhone);
        insert con;
        
        Contact[] insertedContacts = [Select phone,HomePhone,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(newPhone,insertedContacts[0].Phone);
        system.assertEquals(newPhone,insertedContacts[0].HomePhone);
        system.assertEquals(preferredPhone,insertedContacts[0].PreferredPhone__c);
        
        //test work phone
        preferredPhone = 'Work';
        
        Contact con1 = new Contact(FirstName='test', LastName='contact678',WorkPhone__c=newPhone,PreferredPhone__c=preferredPhone);
        insert con1;
        
        Contact[] insertedContacts1 = [Select phone,WorkPhone__c,PreferredPhone__c from Contact where id=:con1.id];
        
        system.assertEquals(newPhone,insertedContacts1[0].Phone);
        system.assertEquals(newPhone,insertedContacts1[0].WorkPhone__c);
        system.assertEquals(preferredPhone,insertedContacts1[0].PreferredPhone__c);
        
        //test mobile phone
        preferredPhone = 'Mobile';
        
        Contact con2 = new Contact(FirstName='test', LastName='contact678',MobilePhone=newPhone,PreferredPhone__c=preferredPhone);
        insert con2;
        
        Contact[] insertedContacts2 = [Select phone,MobilePhone,PreferredPhone__c from Contact where id=:con2.id];
        
        system.assertEquals(newPhone,insertedContacts2[0].Phone);
        system.assertEquals(newPhone,insertedContacts2[0].MobilePhone);
        system.assertEquals(preferredPhone,insertedContacts2[0].PreferredPhone__c);
        
        //test other phone
        preferredPhone = 'Other';
        
        Contact con3 = new Contact(FirstName='test', LastName='contact678',OtherPhone=newPhone,PreferredPhone__c=preferredPhone);
        insert con3;
        
        Contact[] insertedContacts3 = [Select phone,OtherPhone,PreferredPhone__c from Contact where id=:con3.id];
        
        system.assertEquals(newPhone,insertedContacts3[0].Phone);
        system.assertEquals(newPhone,insertedContacts3[0].OtherPhone);
        system.assertEquals(preferredPhone,insertedContacts3[0].PreferredPhone__c);
        
    }
    
    /// <name> updateContactWithNumberAndPref </name>
    /// <summary> Test Method for updating a contact with a phone number in the correct field
    /// and the preferred phone set. </summary>
    static testMethod void updateContactWithNumberAndPref()
    {
        //with pref set to Home, HomePhone should land in Phone and set PreferredPhone__c to 'home'.
        
        String newPhone = '206-777-7777';
        String preferredPhone = 'Home';
        Contact con = new Contact(FirstName='test', LastName='contact678',HomePhone=newPhone,PreferredPhone__c=preferredPhone);
        insert con;
        
        Contact[] insertedContacts = [Select phone,HomePhone,PreferredPhone__c from Contact where id=:con.id];
        
        //test work phone
        preferredPhone = 'Work';
        String workPhone = '206-888-8888';
        
        con.WorkPhone__c = workPhone;
        con.PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS;
        update con;
        
        Contact[] insertedContacts1 = [Select phone,HomePhone,WorkPhone__c,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(workPhone,insertedContacts1[0].Phone);
        system.assertEquals(workPhone,insertedContacts1[0].WorkPhone__c);
        system.assertEquals(newPhone,insertedContacts1[0].HomePhone);
        system.assertEquals(preferredPhone,insertedContacts1[0].PreferredPhone__c);
        
        //test mobile phone
        preferredPhone = 'Mobile';
        String mobilePhone = '206-999-9999';
        
        con.MobilePhone = mobilePhone;
        con.PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS;
        update con;
        
        Contact[] insertedContacts2 = [Select phone,HomePhone,WorkPhone__c,MobilePhone,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(mobilePhone,insertedContacts2[0].Phone);
        system.assertEquals(mobilePhone,insertedContacts2[0].MobilePhone);
        system.assertEquals(workPhone,insertedContacts2[0].WorkPhone__c);
        system.assertEquals(newPhone,insertedContacts2[0].HomePhone);
        system.assertEquals(preferredPhone,insertedContacts2[0].PreferredPhone__c);
        
        //test other phone
        preferredPhone = 'Other';
        String otherPhone = '206-666-6666';
        
        con.OtherPhone = otherPhone;
        con.PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS;
        update con;
        
        Contact[] insertedContacts3 = [Select phone,HomePhone,WorkPhone__c,MobilePhone,OtherPhone,PreferredPhone__c from Contact where id=:con.id];
        
        system.assertEquals(otherPhone,insertedContacts3[0].Phone);
        system.assertEquals(otherPhone,insertedContacts3[0].OtherPhone);
        system.assertEquals(mobilePhone,insertedContacts3[0].MobilePhone);
        system.assertEquals(workPhone,insertedContacts3[0].WorkPhone__c);
        system.assertEquals(newPhone,insertedContacts3[0].HomePhone);
        system.assertEquals(preferredPhone,insertedContacts3[0].PreferredPhone__c);
        
    }
   */

/* TESTING EMAIL WORKFLOW --------------------------------------------------------------
    /// <name> createContactWithEmailNoPref </name>
    /// <summary> Test Method for creating a contact with an email and no preferences set. </summary>
    static testMethod void createContactWithEmailNoPref()
    {
        //with no other prefs, email should land in workemail__c and set Preferred_Email__c to 'work'.
        String newEmail = 'joe@testforemail.com';
        String preferredEmail = null;
        String workEmailString = 'Work';
        Contact con = new Contact(FirstName='test', LastName='contact678',email=newEmail,Preferred_Email__c=preferredEmail);
        insert con;
        
        Contact[] insertedContacts = [Select email,workEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(newEmail,insertedContacts[0].email);
        system.assertEquals(newEmail,insertedContacts[0].workEmail__c);
        system.assertEquals(workEmailString,insertedContacts[0].Preferred_Email__c);
        
    }
    
    /// <name> createContactWithEmailPersonalPrefAlsoPersonalEmail </name>
    /// <summary> Test Method for creating a contact with a email and a personal email. </summary>
    static testMethod void createContactWithEmailPersonalPrefAlsoPersonalEmail()
    {
        //with pref set to Personal, Personal email should land in email and set Preferred_Email__c to 'Personal'.
        String newEmail = 'joe@testforemail.com';
        String newPersonalEmail = 'j@testemail.net';
        String preferredEmail = 'Personal';
        Contact con = new Contact(FirstName='test', LastName='contact678',email=newEmail,HomeEmail__c=newPersonalEmail,Preferred_Email__c=preferredEmail);
        insert con;
        
        Contact[] insertedContacts = [Select email,workEmail__c,HomeEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(newEmail,insertedContacts[0].email);
        system.assertEquals(newEmail,insertedContacts[0].HomeEmail__c);
        system.assertEquals(null,insertedContacts[0].workEmail__c);
        system.assertEquals(preferredEmail,insertedContacts[0].Preferred_Email__c);
        
    }
    
    /// <name> createContactWithEmailPrefSet </name>
    /// <summary> Test Method for creating a contact with an email in email and the preferred email set. </summary>
    static testMethod void createContactWithEmailPrefSet()
    {
        //with pref set to Home, Personal Email should land in email and set Preferred_Email__c to 'Personal'.
        //commented out until #49 is fixed
        String newEmail = 'joe@testforemail.com';
        String preferredEmail = 'Personal';
        Contact con = new Contact(FirstName='test', LastName='contact678',email=newEmail,Preferred_Email__c=preferredEmail);
        insert con;
        
        Contact[] insertedContacts = [Select email,HomeEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(newEmail,insertedContacts[0].email);
       //   system.assertEquals(newEmail,insertedContacts[0].HomeEmail__c);
        system.assertEquals(preferredEmail,insertedContacts[0].Preferred_Email__c);
        
        //test work email
        preferredEmail = 'Work';
        
        Contact con1 = new Contact(FirstName='test', LastName='contact678',email=newEmail,Preferred_Email__c=preferredEmail);
        insert con1;
        
        Contact[] insertedContacts1 = [Select email,workEmail__c,Preferred_Email__c from Contact where id=:con1.id];
        
        system.assertEquals(newEmail,insertedContacts1[0].email);
        system.assertEquals(newEmail,insertedContacts1[0].workEmail__c);
        system.assertEquals(preferredEmail,insertedContacts1[0].Preferred_Email__c);
        
        //test alternate email
        preferredEmail = 'Alternate';
        
        Contact con2 = new Contact(FirstName='test', LastName='contact678',email=newEmail,Preferred_Email__c=preferredEmail);
        insert con2;
        
        Contact[] insertedContacts2 = [Select email,AlternateEmail__c,Preferred_Email__c from Contact where id=:con2.id];
        
        system.assertEquals(newEmail,insertedContacts2[0].email);
        system.assertEquals(newEmail,insertedContacts2[0].AlternateEmail__c);
        system.assertEquals(preferredEmail,insertedContacts2[0].Preferred_Email__c);
      
    }
    
    /// <name> createContactWithEmailAndPrefSet </name>
    /// <summary> Test Method for creating a contact with a email in the correct field
    /// and the preferred email set. </summary>
    static testMethod void createContactWithEmailAndPrefSet()
    {
        //with pref set to Home, Personal Email should land in email and set Preferred_Email__c to 'Personal'.
        
        String newEmail = 'joe@testforemail.com';
        String preferredEmail = 'Personal';
        Contact con = new Contact(FirstName='test', LastName='contact678',HomeEmail__c=newEmail,Preferred_Email__c=preferredEmail);
        insert con;
        
        Contact[] insertedContacts = [Select email,HomeEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(newEmail,insertedContacts[0].email);
        system.assertEquals(newEmail,insertedContacts[0].HomeEmail__c);
        system.assertEquals(preferredEmail,insertedContacts[0].Preferred_Email__c);
        
        //test work email
        preferredEmail = 'Work';
        
        Contact con1 = new Contact(FirstName='test', LastName='contact678',workEmail__c=newEmail,Preferred_Email__c=preferredEmail);
        insert con1;
        
        Contact[] insertedContacts1 = [Select email,workEmail__c,Preferred_Email__c from Contact where id=:con1.id];
        
        system.assertEquals(newEmail,insertedContacts1[0].email);
        system.assertEquals(newEmail,insertedContacts1[0].workEmail__c);
        system.assertEquals(preferredEmail,insertedContacts1[0].Preferred_Email__c);
        
        //test mobile email
        preferredEmail = 'Alternate';
        
        Contact con2 = new Contact(FirstName='test', LastName='contact678',AlternateEmail__c=newEmail,Preferred_Email__c=preferredEmail);
        insert con2;
        
        Contact[] insertedContacts2 = [Select email,AlternateEmail__c,Preferred_Email__c from Contact where id=:con2.id];
        
        system.assertEquals(newEmail,insertedContacts2[0].email);
        system.assertEquals(newEmail,insertedContacts2[0].AlternateEmail__c);
        system.assertEquals(preferredEmail,insertedContacts2[0].Preferred_Email__c);
       
        
    }
    
    /// <name> updateContactWithEmailAndPref </name>
    /// <summary> Test Method for updating a contact with a email in the correct field
    /// and the preferred email set. </summary>
    static testMethod void updateContactWithEmailAndPref()
    {
        //with pref set to Personal, Personal email should land in email and set Preferred_Email__c to 'Personal'.
        
        String newEmail = 'joe@testforemail.com';
        String preferredEmail = 'Personal';
        Contact con = new Contact(FirstName='test', LastName='contact678',HomeEmail__c=newEmail,Preferred_Email__c=preferredEmail);
        insert con;
        
        Contact[] insertedContacts = [Select email,HomeEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        //test work email
        preferredEmail = 'Work';
        String workEmail = 'jd@email.net';
        
        con.workEmail__c = workEmail;
        con.Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS;
        update con;
        
        Contact[] insertedContacts1 = [Select email,HomeEmail__c,workEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(workEmail,insertedContacts1[0].email);
        system.assertEquals(workEmail,insertedContacts1[0].workEmail__c);
        system.assertEquals(newEmail,insertedContacts1[0].HomeEmail__c);
        system.assertEquals(preferredEmail,insertedContacts1[0].Preferred_Email__c);
        
        //test mobile email
        preferredEmail = 'Alternate';
        String alternateEmail = 'jdc@testemail.net';
        
        con.alternateEmail__c = alternateEmail;
        con.Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS;
        update con;
        
        Contact[] insertedContacts2 = [Select email,HomeEmail__c,workEmail__c,alternateEmail__c,Preferred_Email__c from Contact where id=:con.id];
        
        system.assertEquals(alternateEmail,insertedContacts2[0].email);
        system.assertEquals(alternateEmail,insertedContacts2[0].alternateEmail__c);
        system.assertEquals(workEmail,insertedContacts2[0].workEmail__c);
        system.assertEquals(newEmail,insertedContacts2[0].HomeEmail__c);
        system.assertEquals(preferredEmail,insertedContacts2[0].Preferred_Email__c);
      
        
    }
*/
/* TESTING DONATION HISTORY WEBSERVICES ------------------------------------------------*/

    /// <name> getContactDonationHistory </name>
    /// <summary> Test Method for getContactDonationHistory</summary>
    static testMethod void getContactDonationHistory()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;

        Opportunity o = new Opportunity(Amount=500,Name='test',StageName='Closed Won',CloseDate=System.today());
        insert o;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=o.Id,ContactId=con.Id,isPrimary=true,role='Donor');
        insert ocr;

        Decimal sum = IndividualAccounts.getContactDonationHistory(con.id);
    }

    /// <name> getContactLastDonation </name>
    /// <summary> Test Method for getContactLastDonation</summary>
    static testMethod void getContactLastDonation()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        String sum = IndividualAccounts.getContactLastDonation(con.id);
        
        system.assertEquals('',sum);

        Opportunity o = new Opportunity(Amount=500,Name='test',StageName='Closed Won',CloseDate=System.today());
        insert o;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=o.Id,ContactId=con.Id,isPrimary=true,role='Donor');
        insert ocr;

        sum = IndividualAccounts.getContactLastDonation(con.id);
        
    }


/// <name> getContactDonationHistory </name>
    /// <summary> Test Method for getContactDonationHistory</summary>
    static testMethod void getContactDonationHistoryAmount()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;

        Opportunity o = new Opportunity(Amount=500,Name='test',StageName='Closed Won',CloseDate=System.today());
        insert o;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=o.Id,ContactId=con.Id,isPrimary=true,role='Donor');
        insert ocr;
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        //pass the controller into the extension
        ContactDonationCredit_EXT ext = new ContactDonationCredit_EXT(sc);
        
        system.assertEquals(system.label.DefaultContactTransactionCurrency + '500.00',ext.getContactDonationHistory());
    }

    /// <name> getContactLastDonation </name>
    /// <summary> Test Method for getContactLastDonation</summary>
    static testMethod void getContactLastDonationDate()
    {
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        
        Integer year = 2005;
        Integer month = 10;
        Integer day = 10;
        
        
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);

        Contact con = new Contact(
        	FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS,
        	WorkEmail__c = Constants.CONTACT_EMAIL_FOR_TESTS,
            Preferred_Email__c = Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            WorkPhone__c = Constants.CONTACT_PHONE_FOR_TESTS,
            PreferredPhone__c = Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        String sum = IndividualAccounts.getContactLastDonation(con.id);
        
        system.assertEquals('',sum);

        Opportunity o = new Opportunity(Amount=500,Name='test',StageName='Closed Won',CloseDate=date.newInstance(year,month,day));
        insert o;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=o.Id,ContactId=con.Id,isPrimary=true,role='Donor');
        insert ocr;
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        //pass the controller into the extension
        ContactDonationCredit_EXT ext = new ContactDonationCredit_EXT(sc);

        system.assertEquals(String.valueOf(day) + '/' + String.valueOf(month) + '/' + String.valueOf(year),ext.getContactLastDonation());
        
    }
}