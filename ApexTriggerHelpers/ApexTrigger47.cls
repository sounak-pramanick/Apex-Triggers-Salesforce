public class OpportunityTriggerHelper {
    public static void apexTrigger47(List<Opportunity> newList, Map<Id, Opportunity>oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accIdToMaxOppMap = new Map<Id, String>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.AccountId != null) accIds.add(opp.AccountId);
            }
            else {
                if(opp.AccountId != null && opp.Amount != oldMap.get(opp.Id).Amount) {
                    accIds.add(opp.AccountId);
                    accIds.add(oldMap.get(opp.Id).AccountId);
                }
            }
        }
        
        for(Opportunity opp : [SELECT AccountId, Name FROM Opportunity WHERE AccountId IN :accIds ORDER BY Amount DESC LIMIT 1]) {
            accIdToMaxOppMap.put(opp.AccountId, opp.Name);
        }
        
        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :accIdToMaxOppMap.keySet()]) {
            acc.Description = accIdToMaxOppMap.get(acc.Id);
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