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
* @author Nick Bailey 
* @date 2011 (2.1)
* @description Controls the creation of payment objects from Opportunity trigger
*/
public without sharing class PaymentCreator{

	//user defined rollups in list settings
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappings = new map<string, Payment_Field_Mapping_Settings__c>();
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappingsAll = new map<string, Payment_Field_Mapping_Settings__c>();
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappingsToRemove = new map<string, Payment_Field_Mapping_Settings__c>();

  	//list of payments
	list<OppPayment__c> newPayments = new list<OppPayment__c>();

	public Contacts_And_Orgs_Settings__c ContactSettings;

    //constructor gets opps from trigger??
    public PaymentCreator(Map<id, Opportunity> newOppsMap, Map<id, Opportunity> oldOppsMap, Constants.triggerAction ta) {
        
        ContactSettings = Constants.getContactsSettings();
         			
		if (ContactSettings != null && ContactSettings.Payments_Enabled__c == true){
 			list<Opportunity> newOpps = newOppsMap.values();
 			list<OppPayment__c> paymentsToInsert = new list<OppPayment__c>();
 			list<OppPayment__c> paymentsToUpdate = new list<OppPayment__c>();
 			list<OppPayment__c> paymentsToDelete = new list<OppPayment__c>();
 			list<Opportunity> updatedOpps = new list<Opportunity>();
 			
 			//load custom field mapping settings - if they exist        
        	paymentMappingsAll = Payment_Field_Mapping_Settings__c.getAll().clone();
        	paymentMappings = Payment_Field_Mapping_Settings__c.getAll().clone();
        	
        	
        	for (string s : paymentMappingsAll.keySet()){
	        	Payment_Field_Mapping_Settings__c pfms = paymentMappingsAll.get(s); 
	        
	            SobjectField opportunityField;
	            SobjectField paymentField;
	            boolean isValid = true;
	        
	            //check Opp fields
	            opportunityField = Schema.sObjectType.Opportunity.fields.getMap().get(pfms.Opportunity_Field__c);
	            if (opportunityField == null) isValid = false;
	                      
	            //check Payment fields            
	            paymentField = Schema.sObjectType.OppPayment__c.fields.getMap().get(pfms.Payment_Field__c);
	            if (paymentField == null) isValid = false;
	            
	            //check Field Types
	            Schema.DisplayType payF = paymentField.getDescribe().getType();
	            Schema.DisplayType oppF = opportunityField.getDescribe().getType();
	            if (payF != oppF) isValid = false;
	            
	            if (isValid == false) paymentMappings.keyset().remove(s);
	            	            
        	}
	        
	        //SOQL for Updated Opps and Related Payments.  Queries for known fields and field in custom Payment Field Mappings.
 			if(ta == Constants.triggerAction.afterUpdate){
 				String soqlStatement = '';
	 			soqlStatement += 'select id, CloseDate, Amount, isClosed, isWon, ';
	 			for (string s : paymentMappings.keyset()){
		        	   Payment_Field_Mapping_Settings__c pfms = paymentMappings.get(s);
		        	   soqlStatement += pfms.Opportunity_Field__c + ', '; 	
		        }
		        soqlStatement += 'payments_made__c, (SELECT id, Paid__c, Payment_Amount__c, Payment_Date__c, ';
		        for (string s : paymentMappings.keyset()){
		        	   Payment_Field_Mapping_Settings__c pfms = paymentMappings.get(s);
		        	   soqlStatement += pfms.Payment_Field__c + ', '; 	
		        }
		        soqlStatement += 'scheduled_date__c ';
		        soqlStatement += 'from Opportunity.OppPayment__r) from Opportunity WHERE id in :newOpps';
 				updatedOpps = Database.query(soqlStatement);
 			}
 	
 			//IF Trigger is Insert, Create a new Payment
		    if( ta == Constants.triggerAction.AfterInsert){
		    	
		    	// James Melville Added to support multi-currency sfdc.  */
                // CurrencyIsoCode doesn't exist in non-multi-currency orgs
                SObjectField OppCurrencyField = Schema.sObjectType.Opportunity.fields.getMap().get('CurrencyIsoCode');
                SObjectField PaymentCurrencyField = Schema.sObjectType.OppPayment__c.fields.getMap().get('CurrencyIsoCode');
		    	
		    	for (Opportunity thisOpp : newOpps){
			        // if opp is closed won with no payments scheduled or made, add an automatic payment
			        if( ta == Constants.triggerAction.AfterInsert){
				        if ( /*(thisOpp.IsClosed && thisOpp.IsWon) && */
				                        thisOpp.amount > 0 && thisOpp.payments_made__c == 0 && thisOpp.Number_of_Payments__c == 0 && !thisOpp.Do_Not_Automatically_Create_Payment__c) {
				            	oppPayment__c op = new oppPayment__c(
					            	opportunity__c = thisOpp.id
				            	);
				            	
				            	
				            	//in multicurrency SFDC set the payment currency field to equal to the opp currency
                                if(PaymentCurrencyField != null && OppCurrencyField != null)
                                    op.put(PaymentCurrencyField, thisOpp.get(OppCurrencyField));
				            	
				            	op.payment_amount__c = thisOpp.amount;
				            
				            if (paymentMappings.size() > 0){
					            for (string s : paymentMappings.keyset()){
					                	Payment_Field_Mapping_Settings__c pfms = paymentMappings.get(s);
					                	string x = pfms.Opportunity_Field__c;
					                	if (thisOpp.get(x) != null)
					                	   op.put(pfms.Payment_Field__c, thisOpp.get(x));
					            }
					        }
					        
					        if (thisOpp.IsClosed && thisOpp.IsWon){
				            	op.paid__c = true;
				            	op.payment_date__c = thisOpp.closeDate;
				            }
				            
				            if (!thisOpp.IsClosed){
				            	op.paid__c = false;
				            	op.scheduled_date__c = thisOpp.closeDate;
				            }
					        
				            paymentsToInsert.add(op);
				        }
				        /*
				        else if (!thisOpp.IsClosed && 
				                        thisOpp.amount > 0 && thisOpp.payments_made__c == 0 && thisOpp.Number_of_Payments__c == 0 && !thisOpp.Do_Not_Automatically_Create_Payment__c) {
				        	paymentsToInsert.add(new oppPayment__c(
				                opportunity__c = thisOpp.id,
				                scheduled_date__c = thisOpp.closeDate,
				                payment_amount__c = thisOpp.amount,
				                paid__c = false
				            ));
						}
						*/
			        }	
	        	}
	        	try{
		        	// put in the payment for closed opps       
	    			if (!paymentsToInsert.isEmpty()) insert paymentsToInsert;
		        }
		        catch (DMLException e){
			    	for (OppPayment__c opay : paymentsToInsert) {
			          opay.addError('There was a problem inserting a payment');
			    	}
			    }
			}
			
	        
	        //IF Trigger is Update, keep synced Payments in Sync or delete if Opp is lost
	        if( ta == Constants.triggerAction.AfterUpdate ){
		    	list<Opportunity> oldOpps = oldOppsMap.values();
		    	for (Opportunity thisOpp : updatedOpps){
		    		Opportunity oldOpp = oldOppsMap.get(thisOpp.id);
					
					boolean mappingsUpdated = false;
					
					//check to see if any of the custom mapped fields have been updated
					for (string s : paymentMappings.keyset()){
						if(thisOpp.get(paymentMappings.get(s).Opportunity_Field__c) != oldOpp.get(paymentMappings.get(s).Opportunity_Field__c)){
							mappingsUpdated = true;
						}
					}
		    	
		    	     
                    if (thisOpp.OppPayment__r.size() > 0){
			             // if opp is updated, update the automatic payment
				        if ( ((thisOpp.Amount != oldOpp.Amount) || (thisOpp.CloseDate != oldOpp.CloseDate) || mappingsUpdated == true) &&
					        	(thisOpp.OppPayment__r[0].Scheduled_Date__c == oldOpp.CloseDate || thisOpp.OppPayment__r[0].Scheduled_Date__c == thisOpp.CloseDate) &&
				        		(thisOpp.OppPayment__r[0].Payment_Amount__c == oldOpp.Amount || thisOpp.OppPayment__r[0].Payment_Amount__c == thisOpp.Amount) &&
					        	thisOpp.OppPayment__r.size() == 1 &&
					        	thisOpp.OppPayment__r[0].paid__c == False &&
					        	!thisOpp.isClosed && thisOpp.amount > 0 &&
					        	thisOpp.payments_made__c == 0) {
				           	thisOpp.OppPayment__r[0].scheduled_date__c = thisOpp.closeDate;
				            thisOpp.OppPayment__r[0].payment_amount__c = thisOpp.amount;
				            
				            
				            if (paymentMappings.size() > 0){
					            for (string s : paymentMappings.keyset()){
					                	Payment_Field_Mapping_Settings__c pfms = paymentMappings.get(s);
					                	string x = pfms.Opportunity_Field__c;
					                	if (thisOpp.get(x) != null)
					                	   thisOpp.OppPayment__r[0].put(pfms.Payment_Field__c, thisOpp.get(x));
					            }
					        }
					     
                            paymentsToUpdate.add(thisOpp.OppPayment__r[0]);
				        }
				        else if ( ((thisOpp.Amount != oldOpp.Amount) || (thisOpp.CloseDate != oldOpp.CloseDate) || (thisOpp.isWon != oldOpp.IsWon)) &&
				        		(thisOpp.OppPayment__r[0].scheduled_Date__c == oldOpp.CloseDate || thisOpp.OppPayment__r[0].scheduled_Date__c == thisOpp.CloseDate || thisOpp.OppPayment__r[0].Payment_Date__c == oldOpp.CloseDate || thisOpp.OppPayment__r[0].Payment_Date__c == thisOpp.CloseDate) &&
				        		(thisOpp.OppPayment__r[0].Payment_Amount__c == oldOpp.Amount || thisOpp.OppPayment__r[0].Payment_Amount__c == thisOpp.Amount) &&
				        		thisOpp.OppPayment__r.size() == 1 &&
				        		thisOpp.OppPayment__r[0].paid__c == False &&
				        		thisOpp.isClosed && thisOpp.isWon && thisOpp.amount > 0 &&
				        		thisOpp.payments_made__c == 0) {
				           	thisOpp.OppPayment__r[0].payment_date__c = thisOpp.closeDate;
				            thisOpp.OppPayment__r[0].payment_amount__c = thisOpp.amount;
			                thisOpp.OppPayment__r[0].paid__c = true;
			                paymentsToUpdate.add(thisOpp.OppPayment__r[0]);
                      
				        }
				        else if ( thisOpp.isClosed && !thisOpp.isWon) {
				            
				            for(OppPayment__c thisPayment : thisOpp.OppPayment__r){
				            	if(thisPayment.Paid__c == False){
				            		paymentsToDelete.add(thisPayment);
				            	}
				            }
				        }
                    }  
				        
				        
				        
	        	}
	        	//try{
		        	// update or delete payments     
	    			if (!paymentsToUpdate.isEmpty()) update paymentsToUpdate;
	    			if (!paymentsToDelete.isEmpty()) delete paymentsToDelete;
	        	//}
	        	/*catch (DMLException e){
			    	for (OppPayment__c opay : paymentsToUpdate) {
			          opay.addError('There was a problem updating a payment');
			    	}
			    }*/
	        }
        }
    }
	
	/*** Test Methods ***/ 
	public static testMethod void test_paymentsDisabled_ClosedOpp_Insert() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= false));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = PaymentWizardController.closedWonStage()
        );
        Test.startTest();
        insert opp;
        Test.stopTest();
        OppPayment__c[] opmt = [select id from OppPayment__c WHERE opportunity__c = :opp.Id];
        system.assertEquals(0, opmt.size());
    }
    
    public static testMethod void test_paymentsEnabled_ClosedOpp_Insert() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
          
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = PaymentWizardController.closedWonStage()          
        );
        Test.startTest();
        insert opp;
        test.stopTest();
        
        OppPayment__c[] opmt = [select id, payment_amount__c, paid__c from OppPayment__c WHERE opportunity__c = :opp.Id];
        system.assertEquals(1, opmt.size());
        system.assertEquals(True, opmt[0].paid__c);
        system.assertEquals(1300, opmt[0].payment_amount__c);
    }
    
    public static testMethod void test_paymentsEnabled_ClosedOpp_Insert_DoNotCreatePayment() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = PaymentWizardController.closedWonStage(),
            Do_Not_Automatically_Create_Payment__c = true
        );
        Test.startTest();
        insert opp;
        test.stopTest();
        OppPayment__c[] opmt = [select id, payment_amount__c, paid__c from OppPayment__c WHERE opportunity__c = :opp.Id];
        system.assertEquals(0, opmt.size());
    }
    
    public static testMethod void test_paymentsEnabled_OpenOpp_Insert() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        
        
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = 'Not Posted'
        );
        Test.startTest();
        insert opp;
        test.stopTest();
        
        OppPayment__c[] opmt = [select id,paid__c from OppPayment__c WHERE opportunity__c = :opp.Id];
        system.assertEquals(1, opmt.size());
        system.assertEquals(False, opmt[0].paid__c);
    }
    
    public static testMethod void test_paymentsEnabled_ClosedOpp_SyncPayment() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp1 = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = 'Not Posted'
        );
        
        Test.startTest();
        insert opp1;
        
        OppPayment__c[] opmt = [select id,paid__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        system.assertEquals(1, opmt.size());
        system.assertEquals(False, opmt[0].paid__c);
        
        Opportunity createdOpp = [select id, stagename, Amount, CloseDate from Opportunity where Id = :opp1.id];
        
        createdOpp.Amount = 1500;
        
        update createdOpp;
        
        opmt = [select id,paid__c,Payment_Amount__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        
        system.assertEquals(1500, opmt[0].Payment_Amount__c);
        
        createdOpp.CloseDate = date.newInstance(2002, 11, 11);
        update createdOpp;
        Test.stopTest(); 
        
        opmt = [select id,paid__c,Payment_Amount__c,Payment_Date__c, scheduled_date__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        system.assertEquals(date.newInstance(2002, 11, 11), opmt[0].Scheduled_Date__c);
        
               
    }
    
    public static testMethod void test_paymentsEnabled_LostOpp() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp1 = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = 'Not Posted'
        );
        Test.startTest();
        insert opp1;
        
        OppPayment__c[] opmt = [select id,paid__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        system.assertEquals(1, opmt.size());
        system.assertEquals(False, opmt[0].paid__c);
        
        Opportunity createdOpp = [select id, stagename, Amount, CloseDate from Opportunity where Id = :opp1.id];
        
        createdOpp.stagename = 'Closed Lost';
        
        
        update createdOpp;
        Test.stopTest();       
        
        opmt = [select id,paid__c,Payment_Amount__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        
        system.assertEquals(0, opmt.size());    
        
    }
    
    public static testMethod void test_PaymentMappings(){
    	
    	Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
    	
    	// create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
    	Payment_Field_Mapping_Settings__c testmapping = new Payment_Field_Mapping_Settings__c(
        Name = 'TestMapping',
        Opportunity_Field__c = 'NextStep',
        Payment_Field__c = 'Check_Reference_Number__c'                 
        );
        insert testmapping;        
        Opportunity opp1 = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = date.newInstance(2001,12,12),
            stagename = 'whatever'
        );
        test.startTest();
        insert opp1;
        
        opp1.Amount = 1200;
        update opp1;
        opp1.StageName = PaymentWizardController.closedWonStage();
        opp1.Amount = 1;
        update opp1;     
        test.stopTest();   
    }    
}