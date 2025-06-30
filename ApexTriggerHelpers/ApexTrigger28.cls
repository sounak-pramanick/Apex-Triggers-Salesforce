public class CaseTriggerHelper {
    public static void apexTrigger28(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accIdToNewCaseCountMap = new Map<Id, Integer>();
        Map<Id, Integer> accIdToWorkingCaseCountMap = new Map<Id, Integer>();
        Map<Id, Integer> accIdToEscalatedCaseCountMap = new Map<Id, Integer>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Case cs : newList) {
            if(oldMap == null) {
                if(cs.AccountId != null) accIds.add(cs.AccountId);
            }
            else {
                if(cs.Status != oldMap.get(cs.Id).Status && cs.AccountId != null) accIds.add(cs.AccountId);
                else if(cs.AccountId != null && cs.AccountId != oldMap.get(cs.Id).AccountId) {
                    accIds.add(cs.AccountId);
                    accIds.add(oldMap.get(cs.Id).AccountId);
                }
            }
        }
        
        for(Case cs : [SELECT Id, AccountId, Status FROM Case WHERE AccountId IN :accIds]) {
            if(!accIdToNewCaseCountMap.containsKey(cs.AccountId)) accIdToNewCaseCountMap.put(cs.AccountId, 0);
            if(!accIdToWorkingCaseCountMap.containsKey(cs.AccountId)) accIdToWorkingCaseCountMap.put(cs.AccountId, 0);
            if(!accIdToEscalatedCaseCountMap.containsKey(cs.AccountId)) accIdToEscalatedCaseCountMap.put(cs.AccountId, 0);
            
            if(cs.Status == 'New') {
                accIdToNewCaseCountMap.put(cs.AccountId, accIdToNewCaseCountMap.get(cs.AccountId) + 1);
            }
            else if(cs.Status == 'Working') {
                accIdToWorkingCaseCountMap.put(cs.AccountId, accIdToWorkingCaseCountMap.get(cs.AccountId) + 1);
            }
            else if(cs.Status == 'Escalated') {
                accIdToEscalatedCaseCountMap.put(cs.AccountId, accIdToEscalatedCaseCountMap.get(cs.AccountId) + 1);
            }
        }
        
        for(Account acc : [SELECT Id, Number_of_New_Cases__c, Number_of_Working_Cases__c, Number_of_Escalated_Cases__c
                           FROM Account WHERE Id IN :accIds]) {
        	if(accIdToNewCaseCountMap.containsKey(acc.Id)) acc.Number_of_New_Cases__c = accIdToNewCaseCountMap.get(acc.Id);
			if(accIdToWorkingCaseCountMap.containsKey(acc.Id)) acc.Number_of_Working_Cases__c = accIdToWorkingCaseCountMap.get(acc.Id);
			if(accIdToEscalatedCaseCountMap.containsKey(acc.Id)) acc.Number_of_Escalated_Cases__c = accIdToEscalatedCaseCountMap.get(acc.Id);
            accsToUpdate.add(acc);
        }
        
        if(!accsToUpdate.isEmpty()) {
            try {
                update accsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}