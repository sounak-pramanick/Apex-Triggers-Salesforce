public class CaseTriggerHelper {
    public static void apexTrigger12(List<Case> newList) {
        Map<Id, Case> accIdToCaseMap = new Map<Id, Case>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Case cs : newList) {
            if(cs.AccountId != null) {
                accIdToCaseMap.put(cs.AccountId, cs);
            }
        }
        
        for(Account acc : [SELECT Id, Latest_Case_Inserted__c FROM Account WHERE Id IN :accIdToCaseMap.keySet()]) {
            if(accIdToCaseMap.containsKey(acc.Id)) {
                acc.Latest_Case_Inserted__c = accIdToCaseMap.get(acc.Id).Id;
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