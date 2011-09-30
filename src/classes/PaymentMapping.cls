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
* @author Nick Bailey 
* @date 2011 (2.1)
* @description Controller for the payment mapping wizard
*/
public with sharing class PaymentMapping {
    
    //controls which types to display
    map<string, Schema.Displaytype> mapFieldTypes = new map<string, Schema.Displaytype>();
    map<string, Schema.Displaytype> targetFieldTypes = new map<string, Schema.Displaytype>();
        
    //pickers for setting values   
    public list<SelectOption> sourcefields = new list<SelectOption>();
    public list<SelectOption> validoperators = new list<SelectOption>();
    public list<SelectOption> targetfields = new list<SelectOption>();
    public list<object> mylist = new list<object>();
    
    //defines values for the final list setting
    public string operator{get; set;}    
    public string opptyfield{get; set;}
    public string targetfield{get; set;}
    public string targetobject{get; set;}
       
    //the test string of the rollup
    public string operationstring;
    
    //controls wizard steps
    public integer step{get; set;}
    
    private boolean hasPaymentInsert = false;
    
    //constructor
    public PaymentMapping(){
       step = 0;
    }    
    
    //called on load of the page
    public PageReference checkSettings(){
        //if there are invalid rollups defined, display an error 
        if (!paymentMappingsValid()){
            showMsg('INVALID USER SETTINGS DETECTED - Some payment mappings have been disabled',ApexPages.Severity.ERROR);
            showMsg('Custom Payment Field Mappings reference target or source fields which do not exist.  Please update or delete the invalid mappings to re-enable.', ApexPages.Severity.WARNING);
        }       
        return null;
    }

    public void next(){
    	this.step++;
    }
    public void back(){
        this.step--;
    }
    
    //reset all instance variable and return to initial screen
    public void cancel(){    	
        this.sourcefields.clear();
        this.mapFieldTypes.clear();
        this.validoperators.clear();
        this.targetfields.clear();
        this.opptyfield = null;
        this.operator = null;
        this.targetfield = null;
        this.operationstring = null;
        this.step = 0;      
    }
    
    //retrieve syntax for fields
    public string getOperationString(){
        operationstring = 'Map the ' + this.opptyfield + ' field on Opportunity to the ' + this.targetfield + ' field on Payment?';
        return operationstring;
    }
    
    //retrieve possible target fields for the selected object
    public list<SelectOption> getTargetFields(){ 
        
        targetfields.clear();
        set<string> knownfields;    
        map<string, Schema.Sobjectfield> targetTokenMap = new map<string, Schema.Sobjectfield>();
        targetobject = 'OppPayment__c';
        
        targetTokenMap = Schema.SObjectType.OppPayment__c.fields.getMap().clone();
        knownfields = new set<string>{
        	'Opportunity__c', 'Paid__c', 'Payment_Amount__c', 'Payment_Date__c',
			'Written_Off__c'};
        
        //pop out the known fields
        for (string s : knownfields){
        	s = s.toLowerCase();
        	targetTokenMap.remove(s);
        }
        
        if ((targettokenMap.size() < 75) && (targettokenMap.size() > 0)){
        
            for (string s : targetTokenMap.keyset()){
            	if (s.contains('__c')){
            		Schema.DescribeFieldResult F = targetTokenMap.get(s).getDescribe();
            		Schema.DisplayType payType = targetTokenMap.get(s).getDescribe().getType();
        			Schema.DisplayType oppType = mapFieldTypes.get(opptyfield);  
            		if(payType == oppType){
                		targetfields.add(new SelectOption(f.getName(), s));
            		}                
            	}
                
            }
        }
        
        if (targetfields.size() < 1){            
            targetfields.add(new SelectOption('NO VALID FIELD AVAILABLE', 'NO VALID FIELD AVAILABLE'));
            showMsg('No valid target field was found for the type of rollup defined. Please add a custom field, or select a different object and try again.', ApexPages.Severity.INFO);                
        }
        return targetfields;    
    }
    
    //retrieve valid source fields from opportunity object
    public list<SelectOption> getSourceFields(){
        
        set<string> knownOpptyFields = new set<string>{'Amount', 'CloseDate', 'ExpectedRevenue', 
        	'Probability', 'TotalOpportunityQuantity', 'membership_start_date__c', 'membership_end_date__c'};
        
        if (sourcefields.isEmpty()){
                       
            map<String, Schema.SObjectField> oppFieldTokenList = Schema.SObjectType.Opportunity.fields.getMap(); 
           
            //loop through the map, only get the describe information for fields we don't
            //already recognize, including our own and non-custom fields, we'll add those in a moment
            for(string fieldName : oppFieldTokenList.keyset()){
                if (fieldname.contains('__c') && (!knownopptyFields.contains(fieldName))){
                    Schema.DescribeFieldResult F = oppFieldTokenList.get(fieldName).getDescribe();                  
                    
                    Schema.Displaytype dt = f.getType();
                	sourcefields.add(new SelectOption(f.getName(),fieldname));
                    mapFieldTypes.put(f.getName(), dt);
                }
           }
           //now add our known field types
           for(string knownField : knownopptyFields){
                sourcefields.add(new SelectOption(knownField, knownField));
           
                if((knownfield == 'Amount') || (knownfield == 'ExpectedRevenue'))
                    mapFieldTypes.put(knownfield, Schema.Displaytype.Currency);         
                else if((knownfield == 'CloseDate')||(knownfield == 'membership_start_date__c') || (knownfield == 'membership_end_date__c'))                  
                    mapFieldTypes.put(knownfield, Schema.Displaytype.Date);
                else
                    mapFieldTypes.put(knownfield, Schema.Displaytype.Double);   
           }
        }
       
        return sourceFields;
    }

    //utility to check that existing user defined rollups are valid - called onpageload
    //NOTE: Only checks that target/source fields exist, not operation validity
    private boolean paymentMappingsValid(){
        boolean isValid = true;
        
        map<string, Payment_Field_Mapping_Settings__c> paymentMappings = Payment_Field_Mapping_Settings__c.getAll(); 
    
        for (string s : paymentMappings.keySet()){
            Payment_Field_Mapping_Settings__c pfms = paymentMappings.get(s);
            SobjectField paymentField;
            SobjectField opportunityField;
            
            //check source field
            opportunityField = Schema.sObjectType.Opportunity.fields.getMap().get(pfms.Opportunity_Field__c);
            if (opportunityField == null) isValid = false;
                      
            //check target fields            
            paymentField = Schema.sObjectType.OppPayment__c.fields.getMap().get(pfms.Payment_Field__c);
            if (paymentField == null) isValid = false;
            
            //only if the other checks succeed, get the describe type
            if (isValid == true){
                //check Field Types
                Schema.DisplayType payF = paymentField.getDescribe().getType();
                Schema.DisplayType oppF = opportunityField.getDescribe().getType();
                if (payF != oppF) isValid = false;
            }                
        }    
    
    return isValid;
    }           
        
    //used to render error messages on the VF interface
    private void showMsg(String arg, ApexPages.Severity severity){
        ApexPages.Message myMsg = new ApexPages.Message(severity,arg);
        ApexPages.addMessage(myMsg);
    }    
    
    //save and commit rollup
    public PageReference createMapping(){
    	
    	//fix for possible race condition
    	if (!hasPaymentInsert){
            try{
                map<string, Payment_Field_Mapping_Settings__c> paymentMappings = Payment_Field_Mapping_Settings__c.getAll();
                integer nameNumber = paymentMappings.size();
    	   	    Payment_Field_Mapping_Settings__c newPFMS = new Payment_Field_Mapping_Settings__c(Name = 'CustomMapping' + nameNumber, 
        		Payment_Field__c = targetfield, Opportunity_Field__c = opptyfield
        		);    		
        		insert newPFMS;
    	       	hasPaymentInsert = true;    		
            }
    	
    	   catch(Exception e){
    		  showMsg('An unhandled exception has occurred. Please try again.',ApexPages.Severity.FATAL);
    		  showMsg('Exception type' + e, ApexPages.Severity.INFO);    		 
    	   }
    	}
    	return ApexPages.currentPage().setRedirect(true);
    }   
    
      
    public static testMethod void TEST_paymentMappingSettings() {
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentMapping'));
        
        //pass the controller into the extension
        PaymentMapping controller = new PaymentMapping();
        
        //exercise basic operations
        controller.next();
        system.assertEquals(controller.step, 1);
        controller.next();
        system.assertEquals(controller.step, 2);
        controller.back();
        system.assertEquals(controller.step, 1);
        controller.cancel();
        system.assertEquals(controller.step, 0);
        
        //check settings returns a null pagereference
        PageReference samePage = controller.checkSettings();
        system.assertEquals(samePage, null);
        
        //call the major getter methods
        list<SelectOption> oppyList = controller.getSourceFields();
        controller.opptyfield = 'Amount';
        
        list<SelectOption> targetFieldList = controller.getTargetFields();
        controller.targetfield = 'Birthdate';
        
        string operationdescription = controller.getOperationString();
        controller.createMapping();
        
        
        controller.targetfield = 'Amount_Outstanding__c';
        controller.createMapping();
                        
        controller.targetfield = null;
        controller.createMapping();                         
                        
        //insert invalid payment map to test error handling methods
        Payment_Field_Mapping_Settings__c badurfs = new Payment_Field_Mapping_Settings__c(
        Name = 'Invalid Test Rollup',
        Opportunity_Field__c = 'InvalidTargetField__test',
        Payment_Field__c = 'InvalidSourceField__test'                 
        );
        insert badurfs;
        boolean isValid = controller.paymentMappingsValid();
        
        //check mismatched types
        badurfs.Opportunity_Field__c = 'Amount';
        badurfs.Payment_Field__c = 'Paid__c';
        update badurfs; 
        isValid = controller.paymentMappingsValid();
        
        PageReference pr = controller.checkSettings();       
          
    }
    
}