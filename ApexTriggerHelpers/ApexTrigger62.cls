public class TaskTriggerHelper {
    public static void apexTrigger62(List<Task> newList) {
        Set<Id> accIdToTaskMap = new Set<Id>();
        Map<Id, Id> accIdToAccOwnerIdMap = new Map<Id, Id>();
        Map<Id, Id> accIdToAccOwnerManagerIdMap = new Map<Id, Id>();
        Map<Id, Id> userManagerIdToUserIdMap = new Map<Id, Id>();
        
        for(Task tsk : newList) {
            if(tsk.WhatId != null && tsk.Priority != null) {
                accIdToTaskMap.add(tsk.WhatId);
            }
        }
        
        for(Account acc : [SELECT Id, Owner.ManagerId, OwnerId FROM Account WHERE Id IN :accIdToTaskMap]) {
            accIdToAccOwnerIdMap.put(acc.Id, acc.OwnerId);
            accIdToAccOwnerManagerIdMap.put(acc.Id, acc.Owner.ManagerId);
        }
        
        for(User usr :[SELECT Id, ManagerId FROM User WHERE ManagerId IN :accIdToAccOwnerIdMap.values() AND IsActive = true]) {
            userManagerIdToUserIdMap.put(usr.ManagerId, usr.Id);
        }
        
        for(Task tsk : newList) {
            if(tsk.WhatId != null && tsk.Priority == 'High' && accIdToAccOwnerManagerIdMap.containsKey(tsk.WhatId)) {
                tsk.OwnerId = accIdToAccOwnerManagerIdMap.get(tsk.WhatId);
            }
            else if(tsk.WhatId != null && (tsk.Priority == 'Low' || tsk.Priority == 'Normal') && accIdToAccOwnerIdMap.containsKey(tsk.WhatId)) {
                Id accOwnerId = accIdToAccOwnerIdMap.get(tsk.WhatId);
                if(userManagerIdToUserIdMap.containsKey(accOwnerId)) {
                    tsk.OwnerId = userManagerIdToUserIdMap.get(accOwnerId);
                }
            }
        }
    }
}