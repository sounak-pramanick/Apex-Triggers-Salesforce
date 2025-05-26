public class OpportunityLineItemHelper {
    public static void apexTrigger20(List<OpportunityLineItem> newList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Integer> accIdToOliCountMap = new Map<Id, Integer>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }
        
        for(Opportunity opp : [SELECT AccountId FROM Opportunity WHERE Id IN :oppIds AND AccountId != null]) {
            accIdToOliCountMap.put(opp.AccountId, 0);
        }
        
        for(AggregateResult aggr : [SELECT COUNT(Id) co, Opportunity.AccountId accId
                                    FROM OpportunityLineItem 
									WHERE OpportunityId IN :oppIds
                                    GROUP BY Opportunity.AccountId]) {
            accIdToOliCountMap.put((Id)aggr.get('accId'), (Integer)aggr.get('co'));
        }
        
        for(Account acc : [SELECT Id, Number_of_Products__c FROM Account WHERE Id IN :accIdToOliCountMap.keySet()]) {
            if(accIdToOliCountMap.containsKey(acc.Id)) {
            	acc.Number_of_Products__c = accIdToOliCountMap.get(acc.Id);
                accsToUpdate.add(acc);
            }
        }
        
        if(!accIdToOliCountMap.isEmpty()) {
            try {
                update accsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}