public class ContactTriggerHelper {
    /*
    public static void apexTrigger4(List<Contact> newList, Map<Id,Contact> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Contact> conAccIdToDescMap = new Map<Id, Contact>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Contact con : newList) {
            if(String.isNotBlank(con.Description) && con.Description != oldMap.get(con.Id).Description && con.AccountId != null) {
                conAccIdToDescMap.put(con.AccountId, con);
            }
        }
        
        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :conAccIdToDescMap.keySet()]) {
            acc.Description = conAccIdToDescMap.get(acc.Id).Description;
            accsToUpdate.add(acc);
        }
        
        if(!accsToUpdate.isEmpty()) {
            update accsToUpdate;
        }
    }
    */



    // logic when an account has multiple contacts
    // take all the contacts description and concat with ; and add it to account description
    public static void apexTrigger4(List<Contact> newList, Map<Id,Contact> oldMap) {
        //A1 -> C1, C2, C3
        //A1.D = C1.D;C2.D;C3.D;
        Map<Id, List<Contact>> contactsByAccountId = new Map<Id, List<Contact>>();
        List<Account> accsToUpdate = new List<Account>();

        for(Contact con : newList) {
            Contact oldCon = (oldMap != null && oldMap.containsKey(con.Id)) ? oldMap.get(con.Id) : null;
            
            if(String.isNotBlank(con.Description) && con.AccountId != null && 
            oldCon != null && oldCon.Description != con.Description) {
                if(!contactsByAccountId.containsKey(con.AccountId)) {
                    contactsByAccountId.put(con.AccountId, new List<Contact>());
                }
                contactsByAccountId.get(con.AccountId).add(con);
            }
        }

        for(Account acc : [SELECT Id, Description FROM Account WHERE Id IN :contactsByAccountId.keySet()]) {
            List<Contact> conList = contactsByAccountId.get(acc.Id);
            List<String> descriptions = new List<String>();

            for(Contact con : conList) {
                descriptions.add(con.Description);
            }
            acc.Description = String.join(descriptions, ';');
            accsToUpdate.add(acc);
        }

        if(!accsToUpdate.isEmpty()) {
            try {
                update accsToUpdate;
            }
            catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }
}