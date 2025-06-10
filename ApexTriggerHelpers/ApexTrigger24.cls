public class OpportunityLineItemHelper {
    public static void apexTrigger24(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Id> oppIdToAccIdMap = new Map<Id, Id>();
        Map<Id, Account> accMap;
        List<Account> accsToUpdate = new List<Account>();
        
        for(OpportunityLineItem oli : newList) {
            if(oldMap == null) {
                if(oli.ListPrice > 50000 && oli.OpportunityId != null) {
                    oppIds.add(oli.OpportunityId);
                }
            }
            else {
                if(oli.ListPrice > 50000 && oli.OpportunityId != null && oli.ListPrice != oldMap.get(oli.Id).ListPrice) {
                    oppIds.add(oli.OpportunityId);
                }
            }
        }
        
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds AND AccountId != null]) {
            oppIdToAccIdMap.put(opp.Id, opp.AccountId);
        }
        
        accMap = new Map<Id, Account>([SELECT Id, Number_of_Products__c FROM Account WHERE Id IN :oppIdToAccIdMap.values()]);
        
        for(AggregateResult aggr : [SELECT COUNT(Id) co, OpportunityId FROM OpportunityLineItem 
                                    WHERE OpportunityId IN :oppIds AND ListPrice > 50000 GROUP BY OpportunityId]) {
            Id oppId = (Id)aggr.get('OpportunityId');
			Integer count = (Integer)aggr.get('co');
			Account acc = accMap.get(oppIdToAccIdMap.get(oppId));
            acc.Number_of_Products__c = count;
            accsToUpdate.add(acc);
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