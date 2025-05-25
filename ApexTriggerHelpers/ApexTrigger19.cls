public class AccountTriggerHelper {
    public static void apexTrigger19(List<Account> newList) {
        Map<Id, Contact> accIdToConTactsMap = new Map<Id, Contact>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Account acc : newList) {
            Contact con = new Contact();
            con.LastName = 'Test Con ' + acc.Name;
            con.AccountId = acc.Id;
            accIdToConTactsMap.put(acc.Id, con);
        }
        
        if(!accIdToConTactsMap.isEmpty()) {
            try {
                insert accIdToConTactsMap.values();
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        for(Account acc : newList) {
            if(accIdToConTactsMap.containsKey(acc.Id)) {
                acc.Client_Contact__c = accIdToConTactsMap.get(acc.Id).Id;
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