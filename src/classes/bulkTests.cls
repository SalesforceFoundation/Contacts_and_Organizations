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
* @date 2011 
* @description These bulk tests are not included in the package but are here to test the code in batches of 200 
*/
@isTest
private class bulkTests {
/*
    static testMethod void insertPrivate()
    {
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName,
                Private__c=true
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        Test.stopTest();
        
        Contact[] insertedContacts = [Select FirstName, LastName, AccountId  from Contact where id IN :cons];
        
        //contact should have no AccountId
        system.assertEquals(conCount,insertedContacts.size());
        //contact should have no AccountId
        system.assertEquals(null,insertedContacts[conCount-1].AccountId);
    
    }
    
    static testMethod void insertOneToOne()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        String newContactMailingStreet = '123 Elm St';
        
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
        
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName,
                MailingStreet = newContactMailingStreet
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        Test.stopTest();
        
        Contact[] insertedContacts = [Select FirstName, LastName, Account.Name,Account.npe01__One2OneContact__c,MailingStreet,Account.BillingStreet,Organization_Type__c,Account.SYSTEMIsIndividual__c  from Contact where id IN :cons];
        
        //one contact should have been created
        system.assertEquals(conCount,insertedContacts.size());
        //the account should have the right type
        system.assertEquals(Constants.ONE_TO_ONE_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should be flagged as an individual
        system.assertEquals(true,insertedcontacts[0].Account.SYSTEMIsIndividual__c );
        //the account should have been named correctly
        system.assertEquals(newContactfirstName + ' ' + newContactLastName,insertedcontacts[0].Account.Name);
        //relationship should be bi-directional
        system.assertEquals(insertedcontacts[0].id,insertedcontacts[0].Account.npe01__One2OneContact__c);
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,insertedcontacts[0].Account.BillingStreet);
        system.assertEquals(insertedcontacts[0].MailingStreet,insertedcontacts[0].Account.BillingStreet);
        
        
    }
    
    static testMethod void deleteOneToOne()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
    	
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        String newContactMailingStreet = '123 Elm St';
        
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
        
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName,
                MailingStreet = newContactMailingStreet
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        
        Contact[] insertedContacts = [Select id, AccountId from Contact where id IN :cons];
        List<Id> createdAccountIds = new List<Id>();
        Integer counter = 0;
        Integer consToGetOpps = 10;
        
        for (Contact thisContact : insertedContacts){
            createdAccountIds.add(thisContact.AccountId);
            if (counter<consToGetOpps){
                Opportunity o = new Opportunity(Amount=500,Name='test',StageName='Closed Won',CloseDate=System.today(), AccountId=thisContact.AccountId);
                insert o;           
            }           
            counter++;
        }
        
        delete cons;
        Test.stopTest();
        
        Account[] remainingAccounts = [Select Id from Account where id IN :createdAccountIds];
        
        //one contact should have been created
        system.assertEquals(consToGetOpps,remainingAccounts.size());        
    }
    
    static testMethod void updateOneToOne()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        String newContactMailingStreet = '123 Elm St';
        
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
        
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName,
                MailingStreet = newContactMailingStreet
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        
        Contact[] insertedContacts = [Select FirstName, LastName, Account.Name,Account.npe01__One2OneContact__c,MailingStreet,Account.BillingStreet,Organization_Type__c,Account.SYSTEMIsIndividual__c  from Contact where id IN :cons];
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updatedOtherCity = 'Seattle';
        
        for(Contact thisContact : insertedContacts){            
            thisContact.LastName=updatedContactLastName;
            thisContact.OtherCity = updatedOtherCity;
        }
        
        
        update insertedContacts;
        Test.stopTest();
        
        Contact[] updatedContacts = [Select FirstName, LastName, Account.Name,Account.npe01__One2OneContact__c,MailingStreet,OtherCity,Account.BillingStreet,Account.ShippingCity from Contact where id IN :insertedContacts];
        
        system.assertEquals(conCount,updatedContacts.size());
        //the account should have been named correctly
        system.assertEquals(updatedContacts[0].firstName + ' ' + updatedContacts[0].LastName,updatedContacts[0].Account.Name);
        //relationship should be bi-directional
        system.assertEquals(updatedContacts[0].id,updatedContacts[0].Account.npe01__One2OneContact__c);
        //addresses should be sync'd
        system.assertEquals(newContactMailingStreet,updatedContacts[0].MailingStreet);
        system.assertEquals(updatedOtherCity,updatedContacts[0].Account.ShippingCity);
        system.assertEquals(updatedContacts[0].MailingStreet,updatedContacts[0].Account.BillingStreet);
        system.assertEquals(updatedContacts[0].OtherCity,updatedContacts[0].Account.ShippingCity);
        
    }
    
     static testMethod void detachOneToOne()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id IN :cons];     
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        for(Contact thisContact : insertedContacts){    
            thisContact.AccountId = null;
            thisContact.LastName = updatedContactLastName;
        }
        update insertedContacts;
        Test.stopTest();
        
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.npe01__One2OneContact__c from Contact where id IN :cons];
        
        system.assertEquals(conCount,updatedContacts.size());
        //AccountId of updated contact should match the orignial Account
        system.assertEquals(originalAccountId,updatedContacts[0].AccountId);
    
    }
    
     static testMethod void editContactDuringDetachOneToOne()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        String newContactMailingStreet = '123 Elm St';
        
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
            Contact con = new Contact(
                FirstName=newContactfirstName,
                LastName=newContactLastName,
                MailingStreet = newContactMailingStreet
            );
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        
        Contact[] insertedContacts = [Select AccountId from Contact where id IN :cons];     
        
        Id originalAccountId = insertedContacts[0].AccountId;
        
        String updatedContactLastName = 'Contact_forTestsChange';
        String updateContactMailingStreet = '234 Oak St';
        for(Contact thisContact : insertedContacts){    
        
            thisContact.AccountId = null;
            thisContact.LastName = updatedContactLastName;
            thisContact.MailingStreet = updateContactMailingStreet;
        }
        update insertedContacts;
        Test.stopTest();
        Contact[] updatedContacts = [Select FirstName, LastName, AccountId,Account.Name,Account.npe01__One2OneContact__c,MailingStreet,Organization_Type__c,Account.BillingStreet from Contact where id IN :cons];
        
        system.assertEquals(conCount,updatedContacts.size());
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
    
    static testMethod void attachToIndividualAccount()
    {
    	Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        List<Contact> cons = new List<contact>();
        Integer conCount = 200;
        for(Integer i=0;i<conCount;i++){
            Contact con = new Contact(FirstName='test', LastName='contact');
            cons.add(con);
        }
        Test.startTest();
        insert cons;
        Test.stopTest();
        Contact[] insertedContacts = [Select Account.Name,AccountId,Organization_Type__c from Contact where id IN :cons];
        
        system.assertEquals(conCount,insertedContacts.size());
        //the contact should have the right type
        system.assertEquals(Constants.BUCKET_ORGANIZATION_TYPE,insertedcontacts[0].Organization_Type__c);
        //the account should have been named correctly
        system.assertEquals(Constants.BUCKET_ACCOUNT_NAME,insertedcontacts[0].Account.Name);
        
    }
    
   */
}