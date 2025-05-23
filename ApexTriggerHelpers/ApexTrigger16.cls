public class OpportunityTriggerHelper {
    public static void apexTrigger16(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.Amount != null && opp.AccountId != null) {
                    accIds.add(opp.AccountId);
                }
            }
            else {
                if(opp.Amount != null && opp.AccountId != null && opp.Amount != oldMap.get(opp.Id).Amount) {
                    accIds.add(opp.AccountId);
                }
                else if(opp.Amount != null && opp.AccountId != null && opp.AccountId != oldMap.get(opp.Id).AccountId) {
                    accIds.add(opp.AccountId);
                    accIds.add(oldMap.get(opp.Id).AccountId);
                }
            }
        }
        
        for(Account acc : [SELECT Id, Max_Opportunity_Name__c, 
                           (SELECT Name, Amount FROM Opportunities WHERE Amount != null ORDER BY Amount DESC LIMIT 1) 
                		   FROM Account WHERE Id IN :accIds]) {
            if(acc.Opportunities.size() > 0) {
                acc.Max_Opportunity_Name__c = acc.Opportunities[0].Name;
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