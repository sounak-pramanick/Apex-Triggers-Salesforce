public class ContactTriggerHelper {
	/*
    public static void apexTrigger5(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
            else {
                if(con.AccountId != null && oldMap.get(con.Id).AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId) {
                    accIds.add(con.AccountId);
                    accIds.add(oldMap.get(con.Id).AccountId);
                }
            }
        }
        
        for(Account acc : [SELECT Id, Number_Of_Contacts__c, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds]) {
            acc.Number_of_Contacts__c = acc.Contacts.size();
            accsToUpdate.add(acc);
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
    */

    // another possible way without subquery
    // using map and counting records one by one
    public static void apexTrigger5(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        Map<Id, Decimal> accIdToConCountMap = new Map<Id, Decimal>();
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
            else {
                if(con.AccountId != null && oldMap.get(con.Id).AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId) {
                    accIds.add(con.AccountId);
                    accIds.add(oldMap.get(con.Id).AccountId);
                }
            }
        }
        
        for(Contact con : [Select Id, AccountId from Contact Where AccountId IN :accIds]) {
			if(!accIdToConCountMap.containsKey(con.AccountId)) {
				accIdToConCountMap.put(con.AccountId, 0);
			}
			accIdToConCountMap.put(con.AccountId, accIdToConCountMap.get(con.AccountId) + 1);
		}

		for(Account acc : [Select Id, Number_Of_Contacts__c from Account Where Id IN :accIds]) {
			if(accIdToConCountMap.containsKey(acc.Id)) {
				acc.Number_Of_Contacts__c = accIdToConCountMap.get(acc.Id);
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