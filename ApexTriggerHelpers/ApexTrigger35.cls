public class CaseTriggerHelper {
    public static void apexTrigger35(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Id> accIdToConIdMap = new Map<Id, Id>();
        List<Event> eventsToInsert = new List<Event>();
        List<Case> casesToUpdate = new List<Case>();
        
        for(Case cs : newList) {
            if(cs.AccountId != null) accIds.add(cs.AccountId);
        }
        
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds AND Primary_Contact__c = true]) {
            accIdToConIdMap.put(con.AccountId, con.Id);
        }
        
        for(Case cs : newList) {
            if(cs.AccountId != null && accIdToConIdMap.containsKey(cs.AccountId)) {
                cs.ContactId = accIdToConIdMap.get(cs.AccountId);
                casesToUpdate.add(cs);
                
                Event evt = new Event();
                evt.WhoId = cs.ContactId;
                evt.Subject = cs.Subject;
                eventsToInsert.add(evt);
            }
        }
        
        if(!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        if(!eventsToInsert.isEmpty()) {
            try {
                insert eventsToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}