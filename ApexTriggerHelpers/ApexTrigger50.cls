public class AccountTriggerHelper {
    public static void apexTrigger50(List<Account> newList) {
        List<Contact> consToInsert = new List<Contact>();
        
        for(Account acc : newList) {
            if(acc.Number_of_Contacts__c != null && acc.Number_of_Contacts__c > 0) {
                Decimal numCons = acc.Number_of_Contacts__c;
                
                while(numCons > 0) {
                    Contact con = new Contact();
                    con.FirstName = 'Test';
                    con.LastName = 'Con of Acc - ' + acc.Name + ' ' + numCons;
                    con.AccountId = acc.Id;
                    consToInsert.add(con);
                    numCons--;
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