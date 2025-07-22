public class ContactTriggerHelper {
    public static void apexTrigger53(List<Contact> newList) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> consToUpdate = new List<Contact>();
        
        for(Contact con : newList) {
            if(con.AccountId != null) {
                accIds.add(con.AccountId);
                con.New_Contact__c = true;
            }
        }
        
        for(Contact con : [SELECT Id, AccountId, New_Contact__c FROM Contact WHERE AccountId IN :accIds]) {
            con.New_Contact__c = false;
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
    }
}