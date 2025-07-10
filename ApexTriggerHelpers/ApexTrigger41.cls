public class OpportunityTriggerHelper {
    public static void apexTrigger41(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.Amount != null && opp.IsClosed == true && opp.AccountId != null) {
                    accIds.add(opp.AccountId);
                }
            }
            else {
                if(opp.Amount != null && opp.IsClosed == true && opp.AccountId != null &&
                  (opp.Amount != oldMap.get(opp.Id).Amount) || opp.IsClosed != oldMap.get(opp.Id).IsClosed) {
                    accIds.add(opp.AccountId);
                }
                else if(opp.Amount != null && opp.IsClosed == true && opp.AccountId != null && 
                        opp.AccountId != oldMap.get(opp.Id).AccountId) {
                    accIds.add(opp.AccountId);
					accIds.add(oldMap.get(opp.Id).AccountId);                            
                }
            }
        }
        
        for(Account acc : [SELECT Id, Max_Closed_Opp_Amount__c, (SELECT Id, IsClosed, Amount FROM Opportunities WHERE IsClosed = true) 
                           FROM Account WHERE Id IN :accIds]) {
            if(!acc.Opportunities.isEmpty()) {
                Decimal maxAmt = 0;
                for(Opportunity opp : acc.Opportunities) {
                    if(opp.Amount > maxAmt) maxAmt = opp.Amount;
                }
                acc.Max_Closed_Opp_Amount__c = maxAmt;
                accsToUpdate.add(acc);
            }
        }
        
        if(!accsToUpdate.isEmpty()) {
            try {
                update accsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}