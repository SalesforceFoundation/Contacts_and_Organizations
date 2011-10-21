trigger OpportunityAccount on Opportunity (before insert) {
	
	Contacts_and_Orgs_Settings__c ContactsSettings = Constants.getContactsSettings();
	
	 //Create contact roles as needed for new opps.
    if(Trigger.isBefore && Trigger.isInsert && !ContactsSettings.npe01__DISABLE_OpportunityAccount_trigger__c && ContactsSettings.Enable_Opportunity_Contact_Role_Trigger__c)
    {
        OpportunityContactRoles.opportunityAccounts(Trigger.new); 
    }
	
}