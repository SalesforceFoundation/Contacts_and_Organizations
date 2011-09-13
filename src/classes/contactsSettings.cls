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
* @description Controller for the contactsSettings VF page 
*/
public with sharing class contactsSettings {
    
    public Contacts_and_Orgs_Settings__c settingsToUpdate;
    public Contacts_and_Orgs_Settings__c pageSettings = new Contacts_and_Orgs_Settings__c();
    
    /********Vars for PKG Update Info *************/
    public string getMyVersion(){return string.valueof(Package.Version.Request);}
    public string getMaxVersion(){return pageSettings.Max_Package_Version__c;}
    public string getLastUpdate(){    	
    	DateTime d = pageSettings.Last_Update_Check__c;
        string datestring = d.format('MMMMM dd, yyyy hh:mm:ss a');
    	return datestring;
    }
    public string getpkgupdatestatus(){
    	string status = pageSettings.Has_Package_Update__c;
    	if (status == 'true')
    	   status = 'New Update Available';
    	else if (status == 'false')
    	   status = 'No New Updates Available';
    	else
    	   status = status;
    	   
    	return status;
    }
    /*********************************************/
    
    
    public contactsSettings(){
        
    }
    
    public Contacts_and_Orgs_Settings__c getSettings() {
        pageSettings = Constants.getContactsSettings();
        return pageSettings;
    }
    
    public PageReference onPageLoad(){
        pageSettings = Constants.getContactsSettings();
        
        return null;
    }
    
    public List<SelectOption> getcontactRoles() {
    
        if(contactRoles.size()==0){
            contactRoles.add(new SelectOption(' ','- none -'));
            Schema.DescribeFieldResult F = Schema.sObjectType.OpportunityContactRole.fields.Role; 
            List<Schema.PicklistEntry> P = F.getPicklistValues();
            for(Schema.PicklistEntry pe : P){
                contactRoles.add(new SelectOption(pe.getLabel(), pe.getLabel()));
            }
        }
        return contactRoles;
    }
    
    List<SelectOption> accountmodels;
   
    List<SelectOption> contactRoles = new List<SelectOption>();

    public List<SelectOption> getaccountmodels() {
        if(accountmodels == null){
            accountmodels = new List<SelectOption>();
            accountmodels.add(new SelectOption('One-to-One', 'One-to-One'));
            accountmodels.add(new SelectOption('Individual', 'Individual'));
        }
        return accountmodels;
    }
    
    public void checkForUpdates(){
    	NPSPPkgVersionCheck npvc = new NPSPPkgVersionCheck('npe01');    	
        npvc.NPSPCheckVersion(true);
    }
    
    
    private void showMsg(String arg, ApexPages.Severity severity){
        ApexPages.Message myMsg = new ApexPages.Message(severity,arg);
        ApexPages.addMessage(myMsg);
    }
    
    public void updateSettings(){
        
        update pageSettings;
        showMsg('Contacts and Organizations Settings updated',ApexPages.Severity.INFO);
    }
    
     public static testMethod void TEST_contactSettings() {
        
        Test.setCurrentPageReference(new PageReference('Page.contactSettings'));
        
        //pass the controller into the extension
        contactsSettings controller = new contactsSettings(); 
        controller.onPageLoad();
        system.assertNotEquals(null,controller.getSettings());
        
        List<SelectOption> accountModels =  controller.getaccountmodels(); 
        system.assertEquals(2,accountModels.size());
        
        List<SelectOption> conRoles = controller.getcontactRoles();
        system.assertNotEquals(null,conRoles);
        controller.updateSettings();
        
    }
    
    static testMethod void testFirstRun()
    {
        //get rid of settings
        delete [select id from Contacts_and_Orgs_Settings__c limit 100];
        //get the default value
        String defaultValue;
        boolean aDefaultIsSelected = false;
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.SystemAccountProcessor__c; 
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(Schema.PicklistEntry pe : P){
            if (pe.isDefaultValue()){
                    defaultValue = pe.getValue();
                    break;
            }
        }
         Test.setCurrentPageReference(new PageReference('Page.contactSettings'));
        
        //pass the controller into the extension
        contactsSettings controller = new contactsSettings(); 
        controller.onPageLoad();
        if(defaultValue!=null){
            system.assertEquals(controller.pageSettings.Account_Processor__c,defaultValue);
        } else {
            system.assertEquals(controller.pageSettings.Account_Processor__c,Constants.BUCKET_PROCESSOR);
        }
    }
    

}