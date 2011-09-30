/*
    Copyright (c) 2009, Salesforce.com Foundation
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
* @date 2011 (2.x)
* @description Tests for lead convert override
*/
@isTest
private class TEST_LeadConvertOverride {

    //tests if the company is called Self. End point depends on the model
    public static testMethod void newLeadConversion_Test() {
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
 
        String companyName = 'Individual';
        
        companyName = 'Self';           
        String leadFirstName = '';
        String leadLastName = 'lead for tests_987';
        Lead l = new Lead();
        l.FirstName = leadFirstName;
        l.LastName = leadLastName;
        l.Company = companyName;
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        
        //this should NOT convert the lead - because it is one to one
        PageReference landingPage = ext.convertLead();
        system.assert(landingPage == null);
        
        // fill the lists (for coverage)
        ext.getConList();
        system.assertEquals(2, ext.conList.size());
        ext.getlcStatuses();
        system.assert(ext.lcStatuses.size() > 0);
        
        // this selects the "New" option in the Contact box
        ext.con = 'NEW_CONTACT';
        
        ext.convertOneToOne();
        
        if (Constants.isOneToOne()){                
            Contact[] convertedContacts = [select id, firstname, lastname,Account.Systemisindividual__c from Contact where lastname = :leadLastName];
            //one contact should have been created
            system.assertEquals(1,convertedContacts.size());
            //the account for this contact should be an individual account, no matter the model
            system.assertEquals(true,convertedContacts[0].Account.Systemisindividual__c);
            String accountName = convertedContacts[0].FirstName + ' ' + convertedContacts[0].lastname;
            
            List<Account> createdAccount2 = [select id from Account where name = :accountName];
            system.assertEquals(1,createdAccount2.size());
        } else {
            system.Assert(landingPage.getUrl().contains('leadconvert.jsp'));
        }

    }

    //tests if the company is called Self. End point depends on the model
    public static testMethod void newLeadConversionMerge_Test() {

        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
 
        String companyName = 'Individual';

        companyName = 'Self'; 
        
        // create a contact to merge into
        contact c = new contact(
            FirstName=Constants.CONTACT_FIRSTNAME_FOR_TESTS,
        	LastName=Constants.CONTACT_LASTNAME_FOR_TESTS
        );          
        insert c;
        
        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        
        //this should NOT convert the lead - because it is one to one
        PageReference landingPage = ext.convertLead();
        system.assert(landingPage == null);
        
        // fill the lists (for coverage)
        ext.getConList();
        system.assertEquals(3, ext.conList.size());
        ext.getlcStatuses();
        system.assert(ext.lcStatuses.size() > 0);
        
        // this selects the Merge to <contact> option in the Contact box
        ext.con = c.id;
        
        ext.convertOneToOne();
        
        if (Constants.isOneToOne()){                
            Contact[] convertedContacts = [select id, firstname, lastname,Account.Systemisindividual__c from Contact where lastname = :Constants.CONTACT_LASTNAME_FOR_TESTS];
            lead[] unconvertedLeads = [select id, firstname, lastname from lead where lastname = :Constants.CONTACT_LASTNAME_FOR_TESTS and isconverted = false];
            //no lead still unconverted             
            system.assertEquals(0,unconvertedLeads.size());
            //one contact should have been created
            system.assertEquals(1,convertedContacts.size());
            //the account for this contact should be an individual account, no matter the model
            system.assertEquals(true,convertedContacts[0].Account.Systemisindividual__c);
        } else {
            system.Assert(landingPage.getUrl().contains('leadconvert.jsp'));
        }

    }

    //tests if it's a regular lead conversion in either model
    public static testMethod void newLeadConversionNamedCompany_Test() {

        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
        
        String companyName = 'Individual';
        
        companyName = 'Junky company for tests';

        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        l.Status = 'Open';
        
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        PageReference landingPage = ext.convertLead();
        system.Assert(landingPage.getUrl().contains('leadconvert.jsp'));
    }
    
     //tests if it's a regular lead conversion in either model
    public static testMethod void newLeadConversionNamedCompanyNoFirstName_Test() {

        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride')); 
        
        String companyName = 'Individual';
        
        
        companyName = 'Junky company for tests';

        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        PageReference landingPage = ext.convertLead();
        system.Assert(landingPage.getUrl().contains('leadconvert.jsp'));
    }
    
    //tests if the company has the exact same name as the lead. End point depends on the model
    public static testMethod void newLeadWithCompanyMatchingLeadName_Test() {
        
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.ONE_TO_ONE_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
        
        String companyName = 'Individual';
        
        companyName = 'test lead for tests_989';

        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        PageReference landingPage = ext.convertLead();
        
    }
    
    //make sure the lead conversion respects the bucket model
    public static testMethod void newLeadBucketModelWithCompany(){
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
        
        String companyName = 'FunkyTown USA';
        
        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        //set the toggle
        ext.con = 'NEW_CONTACT';
        
        ext.leadConvStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1].MasterLabel; 
        test.startTest();
        PageReference landingPage = ext.convertOnetoOne();
        test.stopTest();
        
        Contact c = [select id, Account.Name from Contact where FirstName = :Constants.CONTACT_FIRSTNAME_FOR_TESTS and LastName = :Constants.CONTACT_LASTNAME_FOR_TESTS];
        
        //bucket model should forward the company account name
        //and not attach the individual unless no name is provided 
        system.assertEquals('FunkyTown USA', c.Account.Name);	
    }
    
    public static testMethod void newLeadBucketModelWithOutCompany(){
        Contacts_and_Orgs_Settings__c contactSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_and_Orgs_Settings__c (Account_Processor__c = Constants.BUCKET_PROCESSOR));
        Constants.setIndividualAccountForTests(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS);
        
        Test.setCurrentPageReference(new PageReference('Page.LeadConvertOverride'));
        
        String companyName = 'self';
        
        Lead l = new Lead();
        l.FirstName = Constants.CONTACT_FIRSTNAME_FOR_TESTS;
        l.LastName = Constants.CONTACT_LASTNAME_FOR_TESTS;
        l.Company = companyName;
        
        insert l;
        
        system.currentPageReference().getParameters().put('id', l.id);
        
        //pass contact into the controller
        ApexPages.StandardController sc = new ApexPages.standardController(l);
        
        //pass the controller into the extension
        LeadConvertOverride ext = new LeadConvertOverride(sc); 
        //set the toggle
        ext.con = 'NEW_CONTACT';
        
        ext.leadConvStatus = [select MasterLabel from LeadStatus where IsConverted = true limit 1].MasterLabel; 
        test.startTest();
        PageReference landingPage = ext.convertOnetoOne();
        test.stopTest();
        
        Contact c = [select id, Account.Name from Contact where FirstName = :Constants.CONTACT_FIRSTNAME_FOR_TESTS and LastName = :Constants.CONTACT_LASTNAME_FOR_TESTS];
        
        //bucket model should forward the company account name
        //and not attach the individual unless no name is provided 
        system.assertEquals(Constants.INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS, c.Account.Name);   
    }
    
    
}