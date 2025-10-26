public class OpportunityTriggerHelper {
    public static void apexTrigger23(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        List<Task> tasksToUpsert = new List<Task>();
        
        for(Opportunity opp : [SELECT Id, StageName, Name, 
                               (SELECT Id, Subject, Status, Description, WhatId FROM Tasks) 
                               FROM Opportunity WHERE Id IN :newList]) {
            if(opp.StageName != null && oldMap != null && opp.StageName != oldMap.get(opp.Id).StageName) {
                List<Task> taskList = opp.Tasks;
                if(!taskList.isEmpty()) {
                    for(Task tsk : taskList) {
                        tsk.Description = opp.StageName;
                        tasksToUpsert.add(tsk);
                    }
                }
                else {
                    Task tsk = new Task();
                    tsk.Subject = 'New Task ' + opp.Name;
                    tsk.Status = 'In Progress';
                    tsk.WhatId = opp.Id;
                    tsk.Description = opp.StageName;
                    tasksToUpsert.add(tsk);
                }
            }
        }
        
        if(!tasksToUpsert.isEmpty()) {
            try {
                upsert tasksToUpsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}