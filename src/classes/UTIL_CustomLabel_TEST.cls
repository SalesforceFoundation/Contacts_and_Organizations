/*
    Copyright (c) 2017, Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
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
@isTest
private with sharing class UTIL_CustomLabel_TEST {
    
    //we have some packaged labels that we no longer reference by the underlying package.
    //unfortunately, this causes our local DE Orgs to not include them in our local package.
    //so we now refer to them here, just so our DE Orgs will keep the in our local package.
    private static testmethod void keepPackagedLabelsInPackage() {
        string str;
        str = Label.Contacts_Settings_Account_Model_Help_Text;
        str = Label.Contacts_Settings_Contact_Roles_Help_Text;
        str = Label.Contact_Merge_Error_Confirm_Message;
        str = Label.Contact_Merge_Error_Confirm_Message_Households;
        str = Label.Contact_Merge_Error_Confirm_Message_Nothing_Found;
        str = Label.Contact_Merge_Error_Contact_not_found;
        str = Label.Contact_Merge_Error_Lock_failed;
        str = Label.Contact_Merge_Error_Merge_Failed;
        str = Label.Contact_Merge_Error_No_Master;
        str = Label.Contact_Merge_Error_please_retry;
        str = Label.Contact_Merge_Error_Query_Failed;
        str = Label.Contact_Merge_Error_Too_Few_Contacts;
        str = Label.Contact_Merge_Error_Too_Many_Contacts;
        str = Label.Contact_Merge_Step1;
        str = Label.Contact_Merge_Step2;
        str = Label.Contact_Merge_Step3;
        str = Label.Contact_Merge_Step4;
        str = Label.DefaultContactTransactionCurrency;
        str = Label.Matching_Donation_Record_Suffix;
        str = Label.Matching_Donation_Record_Type;
        str = Label.Opportunity_Contact_Role_Error_Bad_Contact_Id;
    }
}