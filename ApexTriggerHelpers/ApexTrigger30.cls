public class AccountTriggerHelper {
    public static void apexTrigger30(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> conList = new List<Contact>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contact> consToUpdate = new List<Contact>();
		        
        for(Account acc : newList) {
            if(acc.Account_Status__c != null && acc.Account_Status__c == 'Closed' && 
               acc.Account_Status__c != oldMap.get(acc.Id).Account_Status__c) {
                accIds.add(acc.Id);
            }
        }
        
        for(Account acc : [SELECT Id, (SELECT Id, Do_Not_Contact__c FROM Contacts), 
         					(SELECT Id FROM Opportunities) 
                           FROM Account WHERE Id IN :accIds]) {
			if(!acc.Contacts.isEmpty()) {
                conList.addAll(acc.Contacts);
            }
            if(!acc.Opportunities.isEmpty()) {
                oppList.addAll(acc.Opportunities);
            }
        }
        
        for(Contact con : conList) {
            con.Do_Not_Contact__c = true;
            consToUpdate.add(con);
        }
        
        if(!consToUpdate.isEmpty()) {
            try {
                update consToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        if(!oppList.isEmpty()) {
            try {
                delete oppList;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}