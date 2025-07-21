public class AccountTriggerHelper {
    public static void apexTrigger51(List<Account> newList, Map<Id, Account> oldMap) {
        Map<Id, DateTime> accIdToLastModifiedDateMap = new Map<Id, DateTime>();
        Map<Id, List<Contact>> accIdToConMap = new Map<Id, List<Contact>>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        if(oldMap == null) return;
        
        for(Account acc : newList) {
            accIdToLastModifiedDateMap.put(acc.Id, oldMap.get(acc.Id).LastModifiedDate);
        }
        
        for(Contact con : [SELECT Id, LastName, AccountId, LastModifiedDate FROM Contact 
                           WHERE AccountId IN :accIdToLastModifiedDateMap.keySet()]) {
			if(con.LastModifiedDate > accIdToLastModifiedDateMap.get(con.AccountId)) {
                if(!accIdToConMap.containsKey(con.AccountId)) accIdToConMap.put(con.AccountId, new List<Contact>());
                accIdToConMap.get(con.AccountId).add(con);
            }
        }
        
        for(Account acc : newList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(acc.OwnerId);
            mail.setToAddresses(new String[] {'test@test.com'});
            mail.setSubject('Account ' + acc.Name + ' has been updated');
            mail.setPlainTextBody('The contact ' + accIdToConMap.get(acc.Id)[0].LastName + ' has been updated');
            mail.setSaveAsActivity(false);
            emailsToSend.add(mail);
        }
        
        if(!emailsToSend.isEmpty()) {
            try {
                System.debug('emailsToSend= ' + emailsToSend);
                Messaging.sendEmail(emailsToSend);
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}