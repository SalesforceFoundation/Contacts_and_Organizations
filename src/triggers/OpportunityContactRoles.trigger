trigger OpportunityContactRoles on Opportunity (after insert) {
	
	Contacts_and_Orgs_Settings__c ContactsSettings = Constants.getContactsSettings();
		
    //Create contact roles as needed for new opps.
    if(Trigger.isAfter && Trigger.isInsert && !ContactsSettings.npe01__DISABLE_OpportunityContactRoles_trigger__c && ContactsSettings.Enable_Opportunity_Contact_Role_Trigger__c)
    {
        OpportunityContactRoles process = new OpportunityContactRoles(Trigger.newMap); 
    }
}