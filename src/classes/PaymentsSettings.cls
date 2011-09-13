public with sharing class PaymentsSettings {
    
    public Payments_Settings__c pageSettings = new Payments_Settings__c();
    
    public PaymentsSettings(){
        
    }
    
     public PageReference getSettingsFirstTime() {
        PaymentCreator myPaymentCreator = new PaymentCreator();
       pageSettings = myPaymentCreator.getPaymentsSettings();
        return null;
    }
    
    public Payments_Settings__c getSettings() {
    	PaymentCreator myPaymentCreator = new PaymentCreator();
       pageSettings = myPaymentCreator.getPaymentsSettings();
       //return new Payments_Settings__c();
        return pageSettings;
    }
   
    
    
    private void showMsg(String arg, ApexPages.Severity severity){
        ApexPages.Message myMsg = new ApexPages.Message(severity,arg);
        ApexPages.addMessage(myMsg);
    }
    
    public void updateSettings(){
        
        update pageSettings;
        showMsg('Payments Settings updated',ApexPages.Severity.INFO);
    }
    
     public static testMethod void TEST_paymentSettings() {
        
        Test.setCurrentPageReference(new PageReference('Page.PaymentsSettings'));
        
        //pass the controller into the extension
        PaymentsSettings controller = new PaymentsSettings(); 
        controller.getSettings();
        system.assertNotEquals(null,controller.getSettings());
        
        
        controller.pageSettings.Payments_Enabled__c = true;
        controller.updateSettings();
        
    }
    
}