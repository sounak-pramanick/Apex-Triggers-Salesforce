public class CaseTriggerHelper {
    public static void apexTrigger31(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accIdToClosedCaseCount = new Map<Id, Integer>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Case cs : newList) {
            if(oldMap == null) {
                if(cs.AccountId != null) {
                    accIds.add(cs.AccountId);
                }
            }
            else {
                if(cs.Status != oldMap.get(cs.Id).Status && cs.AccountId != null) {
                    accIds.add(cs.AccountId);
                }
                else if(cs.AccountId != null && cs.AccountId != oldMap.get(cs.Id).AccountId) {
                    accIds.add(cs.AccountId);
                    accIds.add(oldMap.get(cs.Id).AccountId);
                }
            }
        }
        
        for(AggregateResult aggr : [SELECT COUNT(Id) co, AccountId 
                                    FROM Case WHERE AccountId IN :accIds AND Status = 'Closed' 
                                    GROUP BY AccountId]){
            if(!accIdToClosedCaseCount.containsKey((Id)aggr.get('AccountId'))) {
                accIdToClosedCaseCount.put((Id)aggr.get('AccountId'), (Integer)aggr.get('co'));
            }
        }
        
        for(Account acc : [SELECT Id, Rating FROM Account WHERE Id IN :accIdToClosedCaseCount.keySet()]) {
            if(accIdToClosedCaseCount.containsKey(acc.Id)) {
                Integer closedCaseCount = accIdToClosedCaseCount.get(acc.Id);
                if(closedCaseCount > 5) {
                    acc.Rating = 'Hot';
                }
                else if(closedCaseCount > 2) {
                    acc.Rating = 'Warm';
                }
                else {
                    acc.Rating = 'Cold';
                }
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