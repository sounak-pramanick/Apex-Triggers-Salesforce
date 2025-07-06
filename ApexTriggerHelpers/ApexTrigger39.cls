public class CaseTriggerHelper {
    public static void apexTrigger39(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Id> accIdToConIdMap = new Map<Id, Id>();
        List<Task> tasksToInsert = new List<Task>();
        
        for(Case cs : newList) {
            if(oldMap != null && cs.Escalation_Required__c == true && 
               cs.Escalation_Required__c != oldMap.get(cs.Id).Escalation_Required__c &&
               cs.AccountId != null) {
                accIds.add(cs.AccountId);
            }
        }
        
        for(Account acc : [SELECT Id, (SELECT Id FROM Contacts WHERE Primary_Contact__c = true LIMIT 1) FROM Account WHERE Id IN :accIds]) {
            if(!acc.Contacts.isEmpty()) {
                Contact primaryCon = acc.Contacts[0];
                accIdToConIdMap.put(acc.Id, primaryCon.Id);
            }
        }
        
        for(Case cs : newList) {
            if(oldMap != null && cs.Escalation_Required__c == true && 
               cs.Escalation_Required__c != oldMap.get(cs.Id).Escalation_Required__c &&
               cs.AccountId != null && accIdToConIdMap.containsKey(cs.AccountId)) {
                Task tsk = new Task();
                tsk.Subject = 'Follow up task for case escalation';
                tsk.WhoId = accIdToConIdMap.get(cs.AccountId);
                tasksToInsert.add(tsk);
            }
        }
        
        if(!tasksToInsert.isEmpty()) {
            try {
                insert tasksToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}