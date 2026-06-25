public class AccountTriggerHelper {
    public static void apexTrigger3(List<Account> newList, Map<Id, Account> oldMap) {
        Map<Id, Account> accIdToAccMap = new Map<Id, Account>();
        List<Contact> consToUpdate = new List<Contact>();
        
        for(Account acc : newList) {
            Account oldAcc = (oldMap != null && oldMap.containsKey(acc.Id)) ? oldMap.get(acc.Id) : null;

            if(oldAcc != null && acc.Phone != oldAcc.Phone) {
                accIdToAccMap.put(acc.Id, acc);
			}
        }
        
        for(Contact con : [SELECT Id, AccountId, Phone FROM Contact WHERE AccountId IN :accIdToAccMap.keySet()]) {
            if(accIdToAccMap.containsKey(con.AccountId)) {
				con.Phone = accIdToPhoneMap.get(con.AccountId).Phone;
                consToUpdate.add(con);
			}
        }
        
        if(!consToUpdate.isEmpty()) {
            try {
                update consToUpdate;
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
        }
    }
}