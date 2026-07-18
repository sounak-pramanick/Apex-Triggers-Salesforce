public class OpportunityTriggerHelper {
    /*
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
    */

    // alternative approach
    public static void apexTrigger23(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
		Set<Id> oppIds = new Set<Id>();
		Map<Id, List<Task>> oppIdToTasksMap = new Map<Id, List<Task>>();
        List<Task> tasksToUpsert = new List<Task>();

		for(Opportunity opp : newList) {
			if(oldMap != null && opp.StageName != oldMap.get(opp.Id).StageName) {
				oppIds.add(opp.Id);
			}
		}

		for(Task task : [Select Id, Description, WhatId from Task where WhatId IN :oppIds]) {
			if(!oppIdToTasksMap.containsKey(task.WhatId)) {
				oppIdToTasksMap.put(task.WhatId, new List<Task>());	
			}
			//oppIdToTasksMap.put(task.WhatId, oppIdToTasksMap.get(task.WhatId).add(task));
			oppIdToTasksMap.get(task.WhatId).add(task);
		}

		for(Opportunity opp : newList) {
			if(oldMap != null && opp.StageName != oldMap.get(opp.Id).StageName) {
				if(oppIdToTasksMap.containsKey(opp.Id)) {
					List<Task> existingTasks = oppIdToTasksMap.get(opp.Id);
					for(Task task : existingTasks) {
						task.Description = opp.StageName;
						tasksToUpsert.add(task);
					}
				}
				else {
					Task task = new Task();
                    task.Subject = 'New Task ' + opp.Name;
                    task.Status = 'In Progress';
                    task.WhatId = opp.Id;
                    task.Description = opp.StageName;
                    tasksToUpsert.add(task);
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