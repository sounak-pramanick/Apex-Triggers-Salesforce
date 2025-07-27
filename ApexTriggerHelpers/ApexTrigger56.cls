public class OpportunityTriggerHelper {
     public static void apexTrigger56(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.AccountId != null) accIds.add(opp.AccountId);
            }
            else {
                if(opp.AccountId != null && opp.Amount != oldMap.get(opp.Id).Amount) {
                    accIds.add(opp.AccountId);
                }
                else if(opp.AccountId != null && opp.AccountId != oldMap.get(opp.Id).AccountId) {
                    accIds.add(opp.AccountId);
                    accIds.add(oldMap.get(opp.Id).AccountId);
                }
            }
        }
        
        for(Account acc : [SELECT Id, Description, (SELECT Id, Amount, AccountId FROM Opportunities ORDER BY Amount DESC LIMIT 2) 
                           FROM Account WHERE Id IN :accIds]) {
             if(!acc.Opportunities.isEmpty() && acc.Opportunities.size() == 2) {
                 acc.Description = String.valueOf(acc.Opportunities[1].Amount);
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