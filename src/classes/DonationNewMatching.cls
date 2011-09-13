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
* @date 2011 (1.x)
* @description Deprecated class - used to be controller for VF donation matching button
*/
public class DonationNewMatching {
/*
    private final String url;

    private final Id rId;

    private final Id cId;
    
    private final Opportunity oppty;
    
    public DonationNewMatching(ApexPages.StandardController controller) {
        this.oppty= (Opportunity)controller.getRecord();

        List <RecordType> rts = [select Id from RecordType where SobjectType = 'Opportunity' and Name = 'Matching Donation' limit 1];
        if (rts.size() > 0)
        {
            rId = rts[0].Id;
        }
        else
        {
            rId = null;
        }

        List<OpportunityContactRole> ocr = [Select id, ContactId from OpportunityContactRole where IsPrimary = true and OpportunityId = :oppty.Id limit 1]; 
        if ( ocr.size() > 0 )
        {
            cId = ocr[0].ContactId;
        }
        else
        {
            cId = null;
        }

        String newurl = '/006/e?retURL=%2F';
        newurl += oppty.Id;

        if (rId != null)
        {
            newurl += '&RecordType=';
            newurl += rId;
        }
        newurl += '&cancelURL=%2F';
        newurl += oppty.Id;
        newurl += '&lookupcmpgn=1';
        newurl += '&accid=';
        newurl += oppty.AccountId;
        if (cId != null)
        {
            newurl += '&conid=';
            newurl += cId;
        }
        newurl += '&ent=Opportunity';
        newurl += '&opp3=';
        newurl += oppty.Name;
        url = newurl;
    }


    public String getUrl()
    {
        return url;
    }

    public Id getrId()
    {
        return rId;
    }

    public Id getcId()
    {
        return cId;
    }

*/
}