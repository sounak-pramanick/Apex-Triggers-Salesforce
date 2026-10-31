public class OpportunityTriggerHelper {
    public static void apexTrigger63(List<Opportunity> oldList) {
        Map<Id, List<Task>> oppIdToTasksMap = new Map<Id, List<Task>>();
		Map<Id, Id> accIdToOppIdMap = new Map<Id, Id>();
        List<Task> tasksToUpdate = new List<Task>();
		List<Task> tasksToDelete = new List<Task>();
		
		for(Opportunity opp : [SELECT Id, AccountId, (SELECT Id FROM Tasks) FROM Opportunity WHERE Id IN :oldList]) {
            if(opp.Tasks.size() > 0) {
				oppIdToTasksMap.put(opp.Id, opp.Tasks);
	    	}
	    	if(opp.AccountId != null) {
				accIdToOppIdMap.put(opp.AccountId, opp.Id);
	    	}
		}
		
		for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accIdToOppIdMap.keySet()]) {
			if(accIdToOppIdMap.containsKey(opp.AccountId) && opp.Id != accIdToOppIdMap.get(opp.AccountId)) {
				Id oppId = accIdToOppIdMap.get(opp.AccountId);
				
				for(Task tsk : oppIdToTasksMap.get(oppId)) {
					tsk.WhatId = opp.Id;
					tasksToUpdate.add(tsk);
				}
			}
			else if(accIdToOppIdMap.containsKey(opp.AccountId) && opp.Id == accIdToOppIdMap.get(opp.AccountId)) {
                tasksToDelete.addAll(oppIdToTasksMap.get(opp.Id));
			}
		}
        
		if(!tasksToUpdate.isEmpty()) {
			try {
				update tasksToUpdate;
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
		}

		if(!tasksToDelete.isEmpty()) {
			try {
				delete tasksToDelete;
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
		}
    }

	// another approach
	/*
	public static void apexTrigger63(List<Opportunity> oldList) {
        Map<Id, List<Task>> oppIdToTasksMap = new Map<Id, List<Task>>();
		Map<Id, Id> accIdToOppIdMap = new Map<Id, Id>();
        List<Task> tasksToUpdate = new List<Task>();
		List<Task> tasksToDelete = new List<Task>();
		
		for(Opportunity opp : [SELECT Id, AccountId, (SELECT Id FROM Tasks) FROM Opportunity WHERE Id IN :oldList]) {
            if(opp.Tasks.size() > 0) {
				oppIdToTasksMap.put(opp.Id, opp.Tasks);
	    	}
	    	if(opp.AccountId != null) {
				accIdToOppIdMap.put(opp.AccountId, opp.Id);
	    	}
		}
		
        for(Account acc : [SELECT Id, 
                           (SELECT Id, AccountId FROM Opportunities WHERE Id NOT IN :accIdToOppIdMap.values() LIMIT 1) 
                           FROM Account WHERE Id IN :accIdToOppIdMap.keySet()]) {
			if(acc.Opportunities.size() > 0) {
                Opportunity existingOpp = acc.Opportunities[0];
	            Id oppId = accIdToOppIdMap.get(acc.Id);
	            List<Task> tasks = oppIdToTasksMap.get(oppId);
                
                for(Task tsk : tasks) {
	                tsk.WhatId = existingOpp.Id;
        	        tasksToUpdate.add(tsk);
                }
            }
            else {
                Id oppId = accIdToOppIdMap.get(acc.Id);
	            List<Task> tasks = oppIdToTasksMap.get(oppId);
        	    tasksToDelete.addAll(tasks);
            }
        }
        
		if(!tasksToUpdate.isEmpty()) {
			try {
				update tasksToUpdate;
			}
			catch(Exception e) {
				System.debug(e.getMessage());
			}
		}

		if(!tasksToDelete.isEmpty()) {
			try {
				delete tasksToDelete;
			}
			catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
    }
	*/

	// another approach
	/*
	public static void apexTrigger63(List<Opportunity> oldList) {
        Map<Id, List<Task>> oppIdToTasksMap = new Map<Id, List<Task>>();
		Map<Id, Id> oppIdToAccIdMap = new Map<Id, Id>();
		Map<Id, Opportunity> accIdToOppMap = new Map<Id, Opportunity>();
        List<Task> tasksToUpdate = new List<Task>();
		List<Task> tasksToDelete = new List<Task>();
		
		for(Opportunity opp : oldList) {
			if(opp.AccountId != null) {
				oppIdToAccIdMap.put(opp.Id, opp.AccountId);
			}
		}

		for(Task tsk : [Select Id, WhatId, AccountId from Task where WhatId IN :oppIdToAccIdMap.keySet()]) {
			if(!oppIdToTasksMap.containsKey(tsk.WhatId)) {
				oppIdToTasksMap.put(tsk.WhatId, new List<Task>());
			}
			oppIdToTasksMap.get(tsk.WhatId).add(tsk);
		}

		for(Opportunity opp: [Select Id, AccountId from Opportunity where AccountId IN :oppIdToAccIdMap.values()]) {
			if(oppIdToAccIdMap.containsKey(opp.Id)) {
				accIdToOppMap.put(opp.AccountId, opp);
			}
		}

		for(Opportunity opp : oldList) {
			if(opp.AccountId != null && oppIdToTasksMap.containsKey(opp.Id)) {
				if(accIdToOppMap.containsKey(opp.AccountId)) {
					for(Task tsk : oppIdToTasksMap.values()) {
						tsk.WhatId = accIdToOppMap.get(opp.AccountId).Id;
						tasksToUpdate.add(tsk);
					}
				}
				else {
					tasksToDelete.addAll(oppIdToTasksMap.values());
				}
			}
		}
        
		if(!tasksToUpdate.isEmpty()) {
			try {
				update tasksToUpdate;
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
		}

		if(!tasksToDelete.isEmpty()) {
			try {
				delete tasksToDelete;
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
		}
    }
	*/
}