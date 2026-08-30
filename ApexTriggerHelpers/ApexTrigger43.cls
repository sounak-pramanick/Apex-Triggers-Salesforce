public class AccountTriggerHelper {
    /*
    public static void apexTrigger43(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Contact> consToInsert = new List<Contact>();
        
        for(Account acc : newList) {
            if(oldMap == null) {
                if(acc.Create_Contact__c == true) accIds.add(acc.Id);
            }
            else {
                if(acc.Create_Contact__c == true && oldMap.get(acc.Id).Create_Contact__c == false) accIds.add(acc.Id);
            }
        }
        
        for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accIds]) {
            Contact con = new Contact();
            con.AccountId = acc.Id;
            con.FirstName = acc.Name + '\'s ';
            con.LastName = 'Con';
            consToInsert.add(con);
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
    */

    // alternate approach
    public static void apexTrigger43(List<Account> newList, Map<Id, Account> oldMap) {
        List<Contact> consToInsert = new List<Contact>();

		if(oldMap == null) {
			for(Account acc : newList) {
				if(acc.Create_Contact__c == true) {
					createContact(acc.Id, acc.Name, acc.Phone, consToInsert);
				}
			}
		}
		else {
			for(Account acc : newList) {
				if(acc.Create_Contact__c == true && acc.Create_Contact__c != oldMap.get(acc.Id).Create_Contact__c) {
					createContact(acc.Id, acc.Name, acc.Phone, consToInsert);
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

    private static void createContact(Id accountId, String accountName, String accountPhone, List<Contact> consToInsert) {
		Contact con = new Contact();
		con.AccountId = accountId;
		con.FirstName = accountName + '\'s ';
		con.LastName = 'Contact';
		con.Phone = accountPhone;
		consToInsert.add(con);
	}
}