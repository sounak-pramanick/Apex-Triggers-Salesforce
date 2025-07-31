public class CaseTriggerHelper {
    public static void apexTrigger59(List<Case> oldList) {
        Set<Id> accIds = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for(Case cs : oldList) {
            if(cs.AccountId != null) accIds.add(cs.AccountId);
        }
        
        for(Account acc : [SELECT Id, Name, Owner.Email FROM Account WHERE Id IN :accIds]) {
            Task tsk = new Task();
            tsk.WhatId = acc.Id;
            tsk.Status = 'New';
            tsk.Subject = 'Task from case deletion';
            tasksToInsert.add(tsk);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {acc.Owner.Email});
            mail.setSubject('Case has been deleted');
            mail.setPlainTextBody('Case has been deleted for Account ' + acc.Name);
            mailsToSend.add(mail);
        }
        
        if(!tasksToInsert.isEmpty() && !mailsToSend.isEmpty()) {
            try {
                insert tasksToInsert;
                Messaging.sendEmail(mailsToSend);
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}