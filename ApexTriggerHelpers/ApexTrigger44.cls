public class CaseTriggerHelper {
    public static void apexTrigger44(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();
        
        for(Case cs : newList) {
            if(oldMap == null) {
                if(cs.Create_Task__c == true && cs.AccountId != null) accIds.add(cs.AccountId);
            }
            else {
                if(cs.Create_Task__c == true && oldMap.get(cs.Id).Create_Task__c == false && cs.AccountId != null) accIds.add(cs.AccountId);
            }
        }
        
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true]) {
            Task tsk = new Task();
            tsk.Subject = 'Follow-up task on contact';
            tsk.WhoId = con.Id;
            tsk.Status = 'New';
            tasksToInsert.add(tsk);
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