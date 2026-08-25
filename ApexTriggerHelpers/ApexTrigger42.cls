public class AccountTriggerHelper {
    /*
    public static void apexTrigger42(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Boolean> accIdToHasActiveConMap = new Map<Id, Boolean>();
        
        for(Account acc : newList) {
            if(acc.Account_Status__c == 'Closed' && oldMap != null && oldMap.get(acc.Id).Account_Status__c == 'Open') {
                accIds.add(acc.Id);
            }
        }
        
        for(Account acc : [SELECT Id, (SELECT Id FROM Contacts WHERE Active__c = true) FROM Account WHERE Id IN :accIds]) {
            if(!acc.Contacts.isEmpty()) {
                accIdToHasActiveConMap.put(acc.Id, true);
            }
            else {
                accIdToHasActiveConMap.put(acc.Id, false);
            }
        }
        
        for(Account acc : newList) {
            if(acc.Account_Status__c == 'Closed' && oldMap != null && oldMap.get(acc.Id).Account_Status__c == 'Open') {
                if(accIdToHasActiveConMap.containsKey(acc.Id) && accIdToHasActiveConMap.get(acc.Id) == true) {
                    acc.addError('Account has active contacts, so it cannot be deactivated');
                }
            }
        }
    }
    */

    
    
    // alternate approach
    public static void apexTrigger42(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
		Set<Id> accIdsWithActiveCons = new Set<Id>();

		for(Account acc : newList) {
			if(acc.Status == 'Inactive' && acc.Status != oldMap.get(acc.Id).Status) {
				accIds.add(acc.Id);
			}
		}

		if(accIds.isEmpty()) return;

		for(Contact con : [Select Id, AccountId from Contact where AccountId IN :accIds and IsActive = true]) {
			accIdsWithActiveCons.add(con.AccountId);
		}

		for(Account acc : newList) {
			if(acc.Status == 'Inactive' && acc.Status != oldMap.get(acc.Id).Status && accIdsWithActiveCons.contains(acc.Id)) {
				acc.addError('This account cannot be deactivated as it has active contacts');
			}
		}
    }
}