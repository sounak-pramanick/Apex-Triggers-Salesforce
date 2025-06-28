public class OpportunityLineItemHelper {
    public static void apexTrigger25(List<OpportunityLineItem> newList, Map<Id, OpportunityLineItem> oldMap) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, String> accIdToOLIDescMap = new Map<Id, String>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(OpportunityLineItem oli : newList) {
            if(oldMap == null) {
                if(String.isNotBlank(oli.Description) && oli.OpportunityId != null) {
                    oppIds.add(oli.OpportunityId);
                }
            }
            else {
                if(String.isNotBlank(oli.Description) && oli.Description != oldMap.get(oli.Id).Description && oli.OpportunityId != null) {
                    oppIds.add(oli.OpportunityId);
                }
            }
        }
        
        for(Opportunity opp : [SELECT Id, AccountId, 
                               (SELECT Id, Description FROM OpportunityLineItems ORDER BY LastModifiedDate desc LIMIT 1) 
                               FROM Opportunity WHERE Id IN :oppIds]) {
            accIdToOLIDescMap.put(opp.AccountId, opp.OpportunityLineItems[0].Description);
        }
        
        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :accIdToOLIDescMap.keySet()]) {
            if(accIdToOLIDescMap.containsKey(acc.Id)) {
                acc.Description = accIdToOLIDescMap.get(acc.Id);
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