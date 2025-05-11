public class AccountTriggerHelper {
    public static void apexTrigger7(List<Account> newList, Map<Id, Account> oldMap) {
        List<Contact> consToInsert = new List<Contact>();
        
        for(Account acc : newList) {
            if(oldMap == null) {
                if(acc.Create_Contact__c == true) {
                	Contact con = new Contact();
                	con.LastName = acc.Name + '\'s Contact';
                	con.Phone = acc.Phone != null ? acc.Phone : '';
                	con.AccountId = acc.Id;
                	consToInsert.add(con);
            	}
            }
            else {
                if(acc.Create_Contact__c == true && acc.Create_Contact__c != oldMap.get(acc.Id).Create_Contact__c) {
                    Contact con = new Contact();
                	con.LastName = acc.Name + '\'s Contact';
                	con.Phone = acc.Phone != null ? acc.Phone : '';
                	con.AccountId = acc.Id;
                	consToInsert.add(con);
                }
            }
        }
        
        if(!consToInsert.isEmpty()) {
            try {
                insert consToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}