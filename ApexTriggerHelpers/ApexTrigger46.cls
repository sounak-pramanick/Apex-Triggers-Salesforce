public class AccountTriggerHelper {
    public static void apexTrigger46(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> consToUpdate = new List<Contact>();
        
        for(Account acc : newList) {
            if(acc.Country__c != null && oldMap != null && acc.Country__c != oldMap.get(acc.Id).Country__c) {
                accIds.add(acc.Id);
            }
        }
        
        for(Contact con : [SELECT Id, Account.Country__c, AccountId, Account_Country__c FROM Contact WHERE AccountId IN :accIds]) {
            if(accIds.contains(con.AccountId)) {
                con.Account_Country__c = con.Account.Country__c;
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