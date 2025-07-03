public class ContactTriggerHelper {
    public static void apexTrigger33(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, String> accIdToRecTypeMap = new Map<Id, String>();
        
        if(oldMap == null) {
            for(Contact con : newList) {
            	if(con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
            
            for(Account acc : [SELECT Id, RecordType.Name FROM Account WHERE Id IN :accIds]) {
                accIdToRecTypeMap.put(acc.Id, acc.RecordType.Name);
            }
            
            for(Contact con : newList) {
                if(accIdToRecTypeMap.containsKey(con.AccountId)) {
                    con.Contact_Type__c = accIdToRecTypeMap.get(con.AccountId);
                }
            }
        }
        else {
            for(Contact con : newList) {
                if(con.AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId) {
                	accIds.add(con.AccountId);
					accIds.add(oldMap.get(con.Id).AccountId);
            	}
                else if(con.Contact_Type__c != oldMap.get(con.Id).Contact_Type__c && con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
            
            for(Account acc : [SELECT Id, RecordType.Name FROM Account WHERE Id IN :accIds]) {
                accIdToRecTypeMap.put(acc.Id, acc.RecordType.Name);
            }
            
            for(Contact con : newList) {
                if(accIdToRecTypeMap.containsKey(con.AccountId) && con.Contact_Type__c != accIdToRecTypeMap.get(con.AccountId)) {
                    con.addError('Contact type and account record type should be same');
                }
            }
        }
    }
}