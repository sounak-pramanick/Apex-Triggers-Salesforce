public class AccountTriggerHelper {
    public static void apexTrigger14(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for(Account acc : newList) {
            if(acc.Type != null && oldMap != null && acc.Type != oldMap.get(acc.Id).Type) {
                accIds.add(acc.Id);
            }
        }
        
        for(Contact con : [SELECT Id, LastName, Email, AccountId FROM Contact WHERE AccountId IN :accIds AND Email != null]) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(con.Id);
            email.setToAddresses(new String[]{con.Email});
            email.setSubject('Account Type has been updated for contact ' + con.LastName);
            email.setPlainTextBody('The contact ' + con.LastName + '\'s account type has been updated');
            emailsToSend.add(email);
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}