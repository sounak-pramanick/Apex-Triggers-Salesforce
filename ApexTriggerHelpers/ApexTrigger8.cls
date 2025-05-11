public class OpportunityTriggerHelper {
    public static void apexTrigger8(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accIdToOppSumMap = new Map<Id, Decimal>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.AccountId != null && opp.Amount != null) {
                	accIds.add(opp.AccountId);
            	}
            }
            else {
                if(opp.AccountId != null && opp.Amount != null) {
                    if(opp.Amount != oldMap.get(opp.Id).Amount) {
                        accIds.add(opp.AccountId);
                    }
                    if(opp.AccountId != oldMap.get(opp.Id).AccountId) {
                        accIds.add(opp.AccountId);
                        accIds.add(oldMap.get(opp.Id).AccountId);
                    }
                }
            }
        }
        
        for(AggregateResult aggr : [SELECT AccountId, SUM(Amount) sum FROM Opportunity WHERE AccountId IN :accIds GROUP BY AccountId]) {
            accIdToOppSumMap.put((Id)aggr.get('AccountId'), (Decimal)aggr.get('sum'));
        }
        
        for(Account acc : [SELECT Id, Total_Opportunity_Amount__c FROM Account WHERE Id IN :accIds]) {
            if(accIdToOppSumMap.containsKey(acc.Id)) {
                acc.Total_Opportunity_Amount__c = accIdToOppSumMap.get(acc.Id);
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