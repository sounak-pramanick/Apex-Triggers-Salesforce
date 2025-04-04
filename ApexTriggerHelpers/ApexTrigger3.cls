public class AccountTriggerHelper {
    public static void apexTrigger3(List<Account> newList, Map<Id, Account> oldMap) {
        Map<Id, Account> accIdToAccMap = new Map<Id, Account>();
        List<Contact> consToUpdate = new List<Contact>();
        
        for(Account acc : newList) {
            if(acc.Phone != null && acc.Phone != oldMap.get(acc.Id).Phone) {
                accIdToAccMap.put(acc.Id, acc);
            }
        }
        
        for(Contact con : [SELECT Id, AccountId, Phone FROM Contact WHERE AccountId IN :accIdToAccMap.keySet()]) {
            con.Phone = accIdToAccMap.get(con.AccountId).Phone;
            consToUpdate.add(con);
        }
        
        if(!consToUpdate.isEmpty()) {
            update consToUpdate;
        }
    }
}