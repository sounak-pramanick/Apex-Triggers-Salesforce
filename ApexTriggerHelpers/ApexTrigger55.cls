public class ContactTriggerHelper {
    public static void apexTrigger55(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        Map<Id, String> accIdToConMap = new Map<Id, String>();
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.AccountId != null) accIds.add(con.AccountId);
            }
            else {
                if(con.AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId) {
                    accIds.add(con.AccountId);
                    accIds.add(oldMap.get(con.Id).AccountId);
                }
                else if(con.AccountId != null) accIds.add(con.AccountId);
            }
        }
        
        for(Contact con : [SELECT Id, LastName, CreatedDate, AccountId FROM Contact WHERE AccountId IN :accIds]) {
            if(!accIdToConMap.containsKey(con.AccountId)) accIdToConMap.put(con.AccountId, '');
            accIdToConMap.put(con.AccountId, accIdToConMap.get(con.AccountId) + con.LastName + ' - ' + con.CreatedDate + ';');
        }
        
        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :accIdToConMap.keySet()]) {
            if(accIdToConMap.containsKey(acc.Id)) {
                acc.Description = accIdToConMap.get(acc.Id);
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