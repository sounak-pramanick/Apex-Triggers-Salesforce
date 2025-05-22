public class ContactTriggerHelper {
    public static void apexTrigger17(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> existingAccIds = new Set<Id>();
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.Primary_Contact__c && con.AccountId != null) {
                    accIds.add(con.AccountId);
                }
            }
            else {
                if(con.Primary_Contact__c && con.AccountId != null && con.Primary_Contact__c != oldMap.get(con.Id).Primary_Contact__c) {
                    accIds.add(con.AccountId);
                }
                if(con.Primary_Contact__c && con.AccountId != null && con.AccountId != oldMap.get(con.Id).AccountId) {
                    accIds.add(con.AccountId);
                    accIds.add(oldMap.get(con.Id).AccountId);
                }
            }
        }
        
        for(Contact con : [SELECT Id, AccountId, Primary_Contact__c FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true]) {
            existingAccIds.add(con.AccountId);
        }
        
        for(Contact con : newList) {
            if(con.Primary_Contact__c && con.AccountId != null && existingAccIds.contains(con.AccountId)) {
                con.addError('An account can have only one Primary Contact');
            }
        }
    }
}