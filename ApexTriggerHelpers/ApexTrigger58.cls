public class ContactTriggerHelper {
    public static void apexTrigger58(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id, String> accIdToConPhoneMap = new Map<Id, String>();
        Map<Id, List<Contact>> accIdToConMap = new Map<Id, List<Contact>>();
        List<Contact> conList = new List<Contact>();
        List<sObject> objToUpdate = new List<sObject>();
        
        for(Contact con : newList) {
            if(con.AccountId != null && con.Phone != null && oldMap != null && con.Phone != oldMap.get(con.Id).Phone) {
                accIdToConPhoneMap.put(con.AccountId, con.Phone);
            }
        }
        
        for(Account acc : [SELECT Id, Phone, (SELECT Id, Phone, AccountId FROM Contacts) 
                           FROM Account WHERE Id IN :accIdToConPhoneMap.keySet()]) {
            if(accIdToConPhoneMap.containsKey(acc.Id)) {
                acc.Phone = accIdToConPhoneMap.get(acc.Id);
                objToUpdate.add(acc);
                if(!acc.Contacts.isEmpty()) accIdToConMap.put(acc.Id, acc.Contacts);
            }
        }
        
        for(List<Contact> lst : accIdToConMap.values()) {
            conList.addAll(lst);
        }
        
        for(Contact con : conList) {
            if(accIdToConPhoneMap.containsKey(con.AccountId)) {
                con.Phone = accIdToConPhoneMap.get(con.AccountId);
                objToUpdate.add(con);
            }
        }
        
        if(!objToUpdate.isEmpty()) {
            try {
                update objToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}