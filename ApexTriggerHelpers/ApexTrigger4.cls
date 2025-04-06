public class ContactTriggerHelper {
    public static void apexTrigger4(List<Contact> newList, Map<Id,Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Contact> conAccIdToDescMap = new Map<Id, Contact>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Contact con : newList) {
            if(String.isNotBlank(con.Description) && con.Description != oldMap.get(con.Id).Description && con.AccountId != null) {
                conAccIdToDescMap.put(con.AccountId, con);
            }
        }
        
        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :conAccIdToDescMap.keySet()]) {
            acc.Description = conAccIdToDescMap.get(acc.Id).Description;
            accsToUpdate.add(acc);
        }
        
        if(!accsToUpdate.isEmpty()) {
            update accsToUpdate;
        }
    }
}