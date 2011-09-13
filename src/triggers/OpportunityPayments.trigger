trigger OpportunityPayments on Opportunity (after insert, after update) {


  
  /*
    if( Trigger.isAfter && Trigger.isInsert){
        for(Opportunity myNewOpp : trigger.new){
            if (myNewOpp.Do_Not_Automatically_Create_Payment__c == false){
                PaymentCreator process = new PaymentCreator(Trigger.newMap, Trigger.oldMap, Constants.triggerAction.afterInsert);   
            }
        }   
    }
    if( Trigger.isAfter && Trigger.isUpdate ){
        
        for(Opportunity myOldOpp : trigger.old){
            if (myOldOpp.isClosed == false){
                PaymentCreator process = new PaymentCreator(Trigger.newMap, Trigger.oldMap, Constants.triggerAction.afterUpdate);   
            }
        }
    }
    
    */

    if (trigger.isAfter && trigger.isInsert){
        PaymentCreator pc = new PaymentCreator(Trigger.newMap, Trigger.oldMap, Constants.triggerAction.afterInsert);    	
    }
    else if (trigger.isAfter && trigger.isUpdate){
    	PaymentCreator pc = new PaymentCreator(Trigger.newMap, Trigger.oldMap, Constants.triggerAction.afterUpdate);
    }


}