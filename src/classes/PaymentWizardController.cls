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
* @author Evan Callahan & Steve Andersen
* @date 2008/7 (2.1)
* @description Controller for payment creation wizard
*/
public with sharing class PaymentWizardController {

    //Opportunity for the opp we're coming from
    public Opportunity CurrentOpp { get; private set; }

    public boolean haveAmount { get; private set; }
    
    // Class that stores numbered payment
    public class payment {
        public integer paymentNumber { get; private set; }
        public OppPayment__c oppPayment { get; set; }
        
        public payment(integer i) {
            paymentNumber = i;
            oppPayment = new OppPayment__c();
        }
    }

    //values from payments mappings
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappings = new map<string, Payment_Field_Mapping_Settings__c>();
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappingsAll = new map<string, Payment_Field_Mapping_Settings__c>();
    public static map<string, Payment_Field_Mapping_Settings__c> paymentMappingsToRemove = new map<string, Payment_Field_Mapping_Settings__c>();
    
    //which wizard?
    public boolean isWriteoffWizard{get; set;}
    public boolean isScheduleWizard{get; set;}
    
    
    //list of payments
    list<payment> newPayments = new list<payment>();
    //get the payments
    public List<payment> getPayments() {
        return newPayments ;
    }
  
    public oppPayment__c samplePayment { get; set; }
    public oppPayment__c writeoffPayment { get; set; }
    
    //number of outstanding payments for the opp
    public integer outstanding_payments {get; set;}
    
    //decimal for amount float
    public Decimal OppAmountFloat { get; set; }

    //integer for the number of installments to create
    public Integer numberOfPayments { get; set; }

    //integer to hold the interval chosen
    public Integer interval { get; set; }
    
    //boolean to remove paid payments and create a new schedule
    public boolean removePaidPayments { get; set; }

    //public Payments_Settings__c PaymentsSettings;
    public Contacts_and_Orgs_Settings__c PaymentsSettings;
    
    public Contacts_and_Orgs_Settings__c getPaymentsSettings(){
    	if (PaymentsSettings == null)
    	   PaymentsSettings = Constants.getContactsSettings();
    	
    	return PaymentsSettings;
    }
  
    //constructor
    public PaymentWizardController() {
    	
    	if(ApexPages.currentPage().getParameters().get('wtype') == 'writeoff'){
    		PaymentWriteoffWizard();
    		isWriteoffWizard = true;
    		isScheduleWizard = false; 
    		
    	}
    	else if (ApexPages.currentPage().getParameters().get('wtype') == 'payment'){
    		SetupPaymentWizard();
    		isWriteoffWizard = false;
            isScheduleWizard = true;    		
    	}
    	else{    		
    		//error?
    	}    	
    }
    
    public void SetupPaymentWizard() {
        String id = ApexPages.currentPage().getParameters().get('id');
        String query = 'select name, amount, stagename, payments_made__c, amount_outstanding__c, description, closedate, Number_of_Payments__c';
       
        //if currencyiso field exists add it to query for use later
        if(Schema.sObjectType.Opportunity.fields.getMap().get('CurrencyIsoCode') != null)
            query = query + ',CurrencyIsoCode';
            
        query += ' from Opportunity where id = :id';
        opportunity[] o = Database.query(query);
        if (o.isEmpty()) {
            haveAmount = false;
        } else {
            currentOpp = o[0];
            haveAmount = (currentOpp.amount_outstanding__c > 0);
            samplePayment = new OppPayment__c();
            samplePayment.Scheduled_Date__c = system.today();
            numberOfPayments = 12;
            interval = 1;
            intervalUnit = 'Month';
        }
    }
    
    public void PaymentWriteoffWizard() {
        opportunity[] o = [select name, amount, stagename, payments_made__c, amount_outstanding__c, description, closedate, Number_of_Payments__c from Opportunity where id =:ApexPages.currentPage().getParameters().get('id')];
        if (o.isEmpty()) {
            haveAmount = false;
        } else {
            currentOpp = o[0];
            integer paymentcount = 0;
            paymentcount = [select count() from OppPayment__c where Opportunity__c = :o[0].id and Paid__c != true];
            
            outstanding_payments = paymentcount;
            haveAmount = (currentOpp.amount_outstanding__c > 0);
            writeoffPayment = new OppPayment__c();
            writeoffPayment.Payment_Amount__c = currentOpp.amount_outstanding__c;
            writeoffPayment.Written_Off__c = true;
            writeoffPayment.Opportunity__c = currentOpp.Id;
            writeoffPayment.Payment_Date__c = system.today();
        }
    }
    
    public pageReference calculate() {
        if (haveAmount) {
            // clear the list
            newPayments.clear();
                        
            Decimal OppAmountFloat = currentOpp.Amount_Outstanding__c;
    
            //divide the amount by the number of installments, and deal with the remainder
            Decimal paymentAmount = OppAmountFloat.divide(numberOfPayments, 2, system.roundingmode.FLOOR);
            decimal remainder = OppAmountFloat - (paymentAmount * numberOfPayments);
    
            // get the start date
            date nextDate = samplePayment.Scheduled_Date__c;
            
            // Multicurrency support
            // James Melville 05/03/2011 Added to support multi-currency sfdc.  */
            // CurrencyIsoCode doesn't exist in non-multi-currency orgs
            SObjectField OppCurrencyField = Schema.sObjectType.Opportunity.fields.getMap().get('CurrencyIsoCode');
            SObjectField PaymentCurrencyField = Schema.sObjectType.OppPayment__c.fields.getMap().get('CurrencyIsoCode');
            
            for(Integer i=1; i <= numberOfPayments; i++){

                // create the payment record    
                payment thisPayment = new payment(i);
                // set values on the oppPayment object
                thisPayment.oppPayment.Opportunity__c=currentOpp.id;
                thisPayment.oppPayment.Scheduled_Date__c=nextDate;
                thisPayment.oppPayment.payment_method__c=samplePayment.payment_method__c;

                // add the extra pennies, if any
                if (remainder > 0) {
                    thisPayment.oppPayment.Payment_Amount__c = paymentAmount + .01;
                    remainder-=.01;
                } else {
                    thisPayment.oppPayment.Payment_Amount__c = paymentAmount;
                }
                
                //in multicurrency SFDC set the payment currency field to equal the opp currency
                if(PaymentCurrencyField != null && OppCurrencyField != null)
                    thisPayment.oppPayment.put(PaymentCurrencyField,CurrentOpp.get(OppCurrencyField));
                
                //put the payment in the list
                newPayments.add(thisPayment);
    
                //add the interval unit
                if (intervalUnit == 'Week') {
                    nextDate = nextDate.addDays(7 * interval); 
                } else if (intervalUnit == 'Month') {
                    nextDate = nextDate.addMonths(interval); 
                } else if (intervalUnit == 'Year') {
                    nextDate = nextDate.addYears(interval);
                } 
            }
        }
        return null;
    }
    
    public pageReference writeoff() {
        list<OppPayment__c> paymentsToDelete = new list<OppPayment__c>();
        system.debug(CurrentOpp.Id);
        OppPayment__c[] delPymnts = [select id, Paid__c from OppPayment__c where OppPayment__c.Opportunity__c = :CurrentOpp.Id];
        system.debug(delPymnts.size());
        
        for (OppPayment__c thisPayment : delPymnts){
            if(thisPayment.Paid__c == False){
                paymentsToDelete.add(thisPayment);
            }
        }
        system.debug('paymentstodelete: ' + paymentsToDelete.size());
        if (!paymentsToDelete.isEmpty()) delete paymentsToDelete;
        insert writeoffPayment;
        PageReference oldOppPage = new PageReference('/' + currentOpp.id);
        oldOppPage.setRedirect(true);
        return oldOppPage;
    }

    //list of items for picklist of the number of payments to be created
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        for (integer i=1; i<=12; i++) {
            string s=i.format();
            options.add(new SelectOption(s, s));
        }
        return options;
    }

    //list of items for picklist of the interval between payments to be created
    public List<SelectOption> getIntervals() {
        List<SelectOption> options = new List<SelectOption>();
        for (integer i=1; i<=12; i++) {
            string s=i.format();
            options.add(new SelectOption(s, s));
        }
        return options;
    }

    //the unit of the interval
    public String intervalUnit { get; set; }

    //list of items for picklist of the interval unit between payments to be created
    public List<SelectOption> getIntervalUnits() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Week','Week'));
        options.add(new SelectOption('Month','Month'));
        options.add(new SelectOption('Year','Year'));
        return options;
    }

    public PageReference createPayments() {
        // first delete unpaid payments
        oppPayment__c[] old = [select id from oppPayment__c where opportunity__c = :currentOpp.id and paid__c = false];
        if (!old.isEmpty()) delete old;
        
        // If deleting paid Payments, delete paid payments
        oppPayment__c[] oldPaid = [select id from oppPayment__c where opportunity__c = :currentOpp.id and paid__c = true];
        if (!old.isEmpty() && removePaidPayments == true) delete oldPaid;
        
        // get the new payments into a list
        oppPayment__c[] pmts = new oppPayment__c[0];
        for (payment p : newPayments) pmts.add(p.oppPayment);
        
        // create the payment records
        insert pmts;
        
        // Send the user to the detail page for the new account.
        PageReference oldOppPage = new PageReference('/' + currentOpp.id);
        oldOppPage.setRedirect(true);
        return oldOppPage;
    }
    
    public pageReference RemovePaidPayments() {
        removePaidPayments = true;
        return null;
    }
   
    /***  TEST METHODS ***/
    @isTest
    public static string closedWonStage(){    	
    	string closedWonStage;
        List<OpportunityStage> closedWonStages = [select masterlabel from opportunitystage where isActive = true and iswon = true];
        if(closedWonStages.size()>0){
            closedWonStage = closedWonStages[0].masterlabel;
        } else {
                closedWonStage = '';
        }
        return closedWonStage;    	
    }     
    

    
    public static testMethod void test_paymentsEnabled_WriteOff() {
        
        Contacts_And_Orgs_Settings__c PaymentsSettingsForTests = Constants.getContactsSettingsForTests(new Contacts_And_Orgs_Settings__c (Payments_Enabled__c= true));
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp1 = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 150,
            closedate = date.newInstance(2001,12,12),
            stagename = closedWonStage()
        );
        insert opp1;
        
        OppPayment__c[] opmtUpdate = [select id,paid__c, payment_amount__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        opmtUpdate[0].payment_amount__c = 50;
        system.assertEquals(true, opmtUpdate[0].paid__c);
        update opmtUpdate;
        
        OppPayment__c newOpmt = new OppPayment__c(
            Opportunity__c = opp1.id,
            Payment_Amount__c = 100,
            Paid__c = false,
            Payment_Date__c = date.newInstance(2001,12,12)
        );
        insert newOpmt;
        
        Test.startTest();
        
        OppPayment__c[] opmtAllStart = [select id, payment_method__c, payment_amount__c, paid__c, written_off__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        system.assertEquals(2, opmtAllStart.size());

        // create the page 
        PageReference pageRef=Page.PaymentWizard; 
        Test.setCurrentPage(pageRef);

        // set the parameter for the contact
        ApexPages.currentPage().getParameters().put('id', opp1.id);
        ApexPages.currentPage().getParameters().put('wtype', 'writeoff');
        
        // instantiate the controller
        PaymentWizardcontroller controller=new PaymentWizardController();
        controller.PaymentWriteoffWizard();
        
        // set values
        controller.writeoffPayment.payment_date__c = date.newInstance(2001,12,12);
        
        // click calculate
        pagereference ref = controller.writeoff();

        Test.stopTest();
        
        // look for the data
        //should be two, one paid, one written off for the balance 
        OppPayment__c[] opmtAll = [select id, payment_method__c, payment_amount__c, paid__c, written_off__c from OppPayment__c WHERE opportunity__c = :opp1.Id];
        system.assertEquals(2, opmtAll.size());
        
        //the single payment should be written off
        OppPayment__c[] opmtOpen = [select id, payment_method__c, payment_amount__c, paid__c, written_off__c from OppPayment__c WHERE opportunity__c = :opp1.Id and paid__c = false and written_off__c = false];
        system.assertEquals(0, opmtOpen.size());
        
        OppPayment__c[] opmtPaid = [select id, payment_method__c, payment_amount__c, paid__c, written_off__c from OppPayment__c WHERE opportunity__c = :opp1.Id and paid__c = true and written_off__c = false];
        system.assertEquals(1, opmtPaid.size());
        system.assertEquals(50, opmtPaid[0].payment_amount__c);
        
        OppPayment__c[] opmtWrittenOff = [select id, payment_method__c, payment_amount__c, paid__c, written_off__c from OppPayment__c WHERE opportunity__c = :opp1.Id and paid__c = false and written_off__c = true];
        system.assertEquals(1, opmtWrittenOff.size());
        system.assertEquals(100, opmtWrittenOff[0].payment_amount__c);       
    }
    
    public static testMethod void test_PageElementsMonthly() {
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 1300,
            closedate = system.today(),
            stagename = 'Pledged'
        );
        insert opp;
        OppPayment__c[] pmts = new OppPayment__c[0];
        pmts.add( new OppPayment__c (
            opportunity__c = opp.id,
            payment_amount__c = 100,
            paid__c = true )
        );
        pmts.add( new OppPayment__c (
            opportunity__c = opp.id,
            payment_amount__c = 999,
            paid__c = false )
        );
        insert pmts;
         
        Test.startTest();

        // create the page 
        PageReference pageRef=Page.PaymentWizard; 
        Test.setCurrentPage(pageRef); 

        // set the parameter for the contact
        ApexPages.currentPage().getParameters().put('id', opp.id);
        ApexPages.currentPage().getParameters().put('wtype', 'payment');
        
        // instantiate the controller
        PaymentWizardController controller=new PaymentWizardController();
        controller.SetupPaymentWizard();
        
        // get lists
        List<SelectOption> l = controller.getItems();
        l = controller.getIntervals();
        l = controller.getIntervalUnits();
        
        // set values
        controller.samplePayment.payment_method__c = 'Stock';
        
        // click calculate
        pagereference ref = controller.calculate();
        
        // save the page
        string nextPage=controller.createPayments().getUrl(); 

        // look for the data
        OppPayment__c[] opmt = [select id, payment_method__c, payment_amount__c from OppPayment__c WHERE opportunity__c = :opp.Id and paid__c = false];
        system.assertEquals(12, opmt.size());
        system.assertEquals('Stock', opmt[0].payment_method__c);
        system.assertEquals(100, opmt[0].payment_amount__c);

        // verify that the right page displays 
        System.assertEquals(nextPage, '/' + opp.id); 
    }
    
    public static testMethod void test_PageElementsWeekly() {
               
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 400.01,
            closedate = date.newInstance(2001,12,12),
            stagename = 'Pledged'
        );
        insert opp;
         
        Test.startTest();

        // create the page 
        PageReference pageRef=Page.PaymentWizard; 
        Test.setCurrentPage(pageRef); 

        // set the parameter for the contact
        ApexPages.currentPage().getParameters().put('id', opp.id);
        ApexPages.currentPage().getParameters().put('wtype', 'payment');      
        
        // instantiate the controller
        PaymentWizardController controller=new PaymentWizardController();
        controller.SetupPaymentWizard();
        
        // get lists
        List<SelectOption> l = controller.getItems();
        l = controller.getIntervals();
        l = controller.getIntervalUnits();
        
        // set values
        controller.samplePayment.payment_method__c = 'Stock';
        controller.intervalUnit = 'Week';
        controller.numberOfPayments = 4;
        controller.samplePayment.Scheduled_Date__c = date.newInstance(2001,12,12);
        
        // click calculate
        pagereference ref = controller.calculate();
        
        // save the page
        string nextPage=controller.createPayments().getUrl(); 

        // look for the data
        OppPayment__c[] opmt = [select id, payment_method__c, payment_amount__c, scheduled_date__c from OppPayment__c WHERE opportunity__c = :opp.Id and paid__c = false order by scheduled_date__c asc];
        system.assertEquals(4, opmt.size());
        system.assertEquals('Stock', opmt[0].payment_method__c);        
        //system.assertEquals(100, opmt[0].payment_amount__c);
        system.assertEquals(opmt[1].scheduled_date__c, opmt[0].scheduled_date__c.addDays(7));
    }
    
    public static testMethod void test_PageElementsYearly() {
        
        // create test data
        Account acct = new Account (
            Name='Test Account'
        );
        insert acct;
        Opportunity opp = new Opportunity (
            Name='Test Opp',
            AccountId = acct.id,
            Amount = 400,
            closedate = date.newInstance(2001,12,12),
            stagename = 'Pledged'
        );
        insert opp;
         
        Test.startTest();

        // create the page 
        PageReference pageRef=Page.PaymentWizard; 
        Test.setCurrentPage(pageRef); 

        // set the parameter for the contact
        ApexPages.currentPage().getParameters().put('id', opp.id);      
        ApexPages.currentPage().getParameters().put('wtype', 'payment');
        // instantiate the controller
        PaymentWizardController controller=new PaymentWizardController();
        controller.SetupPaymentWizard();
        
        // get lists
        List<SelectOption> l = controller.getItems();
        l = controller.getIntervals();
        l = controller.getIntervalUnits();
        
        // set values
        controller.samplePayment.payment_method__c = 'Stock';
        controller.intervalUnit = 'Year';
        controller.numberOfPayments = 4;
        controller.samplePayment.Scheduled_Date__c = date.newInstance(2001,12,12);
        
        // click calculate
        pagereference ref = controller.calculate();
        
        // save the page
        string nextPage=controller.createPayments().getUrl(); 

        // look for the data
        OppPayment__c[] opmt = [select id, payment_method__c, payment_amount__c, scheduled_date__c from OppPayment__c WHERE opportunity__c = :opp.Id and paid__c = false];
        system.assertEquals(4, opmt.size());
        system.assertEquals('Stock', opmt[0].payment_method__c);
        system.assertEquals(100, opmt[0].payment_amount__c);
        system.assertEquals(opmt[1].scheduled_date__c, opmt[0].scheduled_date__c.addDays(365));
    }
    
    public static testMethod void test_nullOpps() {
    
        // create the page 
        PageReference pageRef=Page.PaymentWizard; 
        Test.setCurrentPage(pageRef);

        // set a bad id
        ApexPages.currentPage().getParameters().put('id', null);
        ApexPages.currentPage().getParameters().put('wtype', 'garbage');
        
        // instantiate the controller
        PaymentWizardController controller=new PaymentWizardController();
        
        //test bad page code
        Test.startTest();
        controller.SetupPaymentWizard();	
        controller.PaymentWriteoffWizard();            	
        Test.stopTest();
    }
    
    public static testMethod void test_publicGetters() {
        
        // instantiate the controller
        PaymentWizardController controller=new PaymentWizardController();
        
        //test public method code
        Test.startTest();      
        controller.getPaymentsSettings();
        list<PaymentWizardController.payment> oplist = controller.getPayments();
        ApexPages.Pagereference pr = controller.RemovePaidPayments();             
        Test.stopTest();
    }    
}