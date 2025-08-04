public class ContactTriggerHelper {
    public static void apexTrigger67(List<Contact> newList) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> prospectAccountsMap;
        List<Case> casesToInsert = new List<Case>();
        
        for(Contact con : newList) {
            if(con.AccountId != null) {
                accIds.add(con.AccountId);
            }
        }
        
        prospectAccountsMap = new Map<Id, Account>([SELECT Id, Type, OwnerId FROM Account WHERE Id IN :accIdS
                                                    AND Type = 'Prospect']); // in question, value is 'Premium'
        
        for(Contact con : newList) {
            if(con.AccountId != null && prospectAccountsMap.containsKey(con.AccountId)) {
                Case cs = new Case();
            	cs.Description = 'A case is created for Contact - ' + con.LastName;
            	cs.OwnerId = prospectAccountsMap.get(con.AccountId).OwnerId;
                cs.AccountId = prospectAccountsMap.get(con.AccountId).Id;
            	casesToInsert.add(cs);
            }
        }
        
        if(!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}