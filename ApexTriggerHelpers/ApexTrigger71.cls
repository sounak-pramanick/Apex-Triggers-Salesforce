public class OpportunityTriggerHelper {
    public static void apexTrigger71(List<Opportunity> newList) {
        // from opps, create map of acc id to latest opp
        // if latest opp created date is < 24 hrs ago, then throw error => now - cd < 24 => now - 24 < cd
        // while iterating on newlist, if any duplicate acc id found, then throw error
        Set<Id> sameTransactionAccIds = new Set<Id>();
        Map<Id, Opportunity> accIdToLatestOppMap = new Map<Id, Opportunity>();
        
        for(Opportunity opp : newList) {
            if(opp.AccountId != null && sameTransactionAccIds.contains(opp.AccountId)) {
                opp.addError('Multiple opportunities cannot be created for the same account in a single transaction');
            }
            else if(opp.AccountId != null && !sameTransactionAccIds.contains(opp.AccountId)) {
                sameTransactionAccIds.add(opp.AccountId);
            }
        }
        
        for(Opportunity existingOpp : [SELECT Id, AccountId, CreatedDate FROM Opportunity 
                                       WHERE AccountId IN :sameTransactionAccIds ORDER BY CreatedDate DESC]) {
			if(!accIdToLatestOppMap.containsKey(existingOpp.AccountId)) {
                accIdToLatestOppMap.put(existingOpp.AccountId, existingOpp);
            }
        }
        
        for(Opportunity opp : newList) {
            if(opp.AccountId != null && accIdToLatestOppMap.containsKey(opp.AccountId) && 
              accIdToLatestOppMap.get(opp.AccountId).CreatedDate > System.now().addDays(-1)) {
                  opp.addError('Multiple opportunities cannot be created for the same account within a day');
              }
        }
    }
}