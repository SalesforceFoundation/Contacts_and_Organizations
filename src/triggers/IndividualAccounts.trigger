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
trigger IndividualAccounts on Contact (before insert, before update, after insert, after update,after delete) {

	
 
    if(Trigger.isInsert && Trigger.isBefore){
        IndividualAccounts process = new IndividualAccounts(Trigger.new, Trigger.old, Constants.triggerAction.beforeInsert);
    }
    if(Trigger.isUpdate && Trigger.isBefore){
        IndividualAccounts process = new IndividualAccounts(Trigger.new, Trigger.old, Constants.triggerAction.beforeUpdate);
    }
    if( Trigger.isAfter && Trigger.isInsert ){
    	//requery to get correct Account values
    	Contact[] newContacts = [select id,SystemAccountProcessor__c,Private__c,AccountId,Account.SYSTEMIsIndividual__c,Account.Name,firstname, lastname from Contact where Id IN :trigger.New];
	        
        IndividualAccounts process = new IndividualAccounts(newContacts, Trigger.old, Constants.triggerAction.afterInsert);
    }
    if( Trigger.isAfter && Trigger.isUpdate ){
	    //requery to get correct Account values
    	Contact[] newContacts = [select id,SystemAccountProcessor__c,Private__c,AccountId,Account.SYSTEMIsIndividual__c,Organization_Type__c,Account.Name,firstname, lastname,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, Phone, Fax from Contact where Id IN :trigger.New];
	    
        IndividualAccounts process = new IndividualAccounts(newContacts, Trigger.old, Constants.triggerAction.afterUpdate);
    }
    if( Trigger.isAfter && Trigger.isDelete ){
        IndividualAccounts process = new IndividualAccounts(Trigger.new, Trigger.old, Constants.triggerAction.afterDelete);
    }
}