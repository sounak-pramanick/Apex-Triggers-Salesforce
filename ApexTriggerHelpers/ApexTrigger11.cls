public class ContactTriggerHelper {
    public static void apexTrigger11(List<Contact> newList) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> accsWithTwoContacts = new Set<Id>();
        
        for(Contact con : newList) {
            if(con.AccountId != null) {
                accIds.add(con.AccountId);
            }
        }
        
        for(Account acc : [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN :accIds]) {
            if(acc.Contacts.size() >= 2) {
                accsWithTwoContacts.add(acc.Id);
            }
        }
        
        for(Contact con : newList) {
            if(con.AccountId != null && accsWithTwoContacts.contains(con.AccountId)) {
                con.addError('This account already has 2 contacts');
            }
        }
    }
}