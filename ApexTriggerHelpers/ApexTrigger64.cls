public class AccountTriggerHelper {
    public static void apexTrigger64(List<Account> newList) {
		Map<Id, Id> accIdToSecondaryOwnerIdMap = new Map<Id, Id>();
		List<AccountShare> accShareList = new List<AccountShare>();

		for(Account acc : newList) {
			if(acc.Secondary_Owner__c != null) {
				accShareList.add(createShareRead(acc.Id, acc.Secondary_Owner__c));
			}
		}

		if(!accShareList.isEmpty()) {
			Database.SaveResult[] srList = Database.insert(accShareList, true);

			for(Database.SaveResult sr : srList) {
				if(!sr.isSuccess()) {
					Database.Error err = sr.getErrors()[0];
				}
			}
		}
	}
    
    public static void apexTrigger64(List<Account> newList, Map<Id, Account> oldMap) {
		List<AccountShare> accShareList = new List<AccountShare>();
        	Set<Id> accIds = new Set<Id>();
        
		for(Account acc : newList) {
			if(oldMap != null && acc.Secondary_Owner__c != oldMap.get(acc.Id).Secondary_Owner__c) {
				accIds.add(acc.Id);
			}
		}

		List<AccountShare> accSharesToDelete = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN :accIds];

		if(!accSharesToDelete.isEmpty()) {
			Database.DeleteResult[] delList = Database.delete(accSharesToDelete, true);
			for(Database.DeleteResult dr : delList) {
				if(!dr.isSuccess()) {
                    Database.Error err = dr.getErrors()[0];
				}
			}

			for(Account acc : newList) {
				if(oldMap != null && acc.Secondary_Owner__c != oldMap.get(acc.Id).Secondary_Owner__c) {
					accShareList.add(createShareRead(acc.Id, acc.Secondary_Owner__c));
				}
			}

			if(!accShareList.isEmpty()) {
				Database.SaveResult[] srList = Database.insert(accShareList, true);

				for(Database.SaveResult sr : srList) {
					if(!sr.isSuccess()) {
						Database.Error err = sr.getErrors()[0];
					}
				}
			}
		}
	}
    
    private static AccountShare createShareRead(Id accRecordId, Id secondaryOwnerId) {
		AccountShare accShare = new AccountShare();
		accShare.AccountId = accRecordId;
		accShare.UserOrGroupId = secondaryOwnerId;
		accShare.AccountAccessLevel = 'Read';
		accShare.RowCause = Schema.AccountShare.RowCause.Manual;
        	return accShare;
	}
}