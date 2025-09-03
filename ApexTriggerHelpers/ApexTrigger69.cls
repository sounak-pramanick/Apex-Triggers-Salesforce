public class Event_Distribution_TriggerHelper {
    public static void apexTrigger69(List<Event_Distribution__c> newList) {
        // evt, cap = 10, 5, 0
        // ed1, dist = 5 
        // ed2, dist = 5
        // ed3, dist = 5, status = waiting
        Map<Id, Event__c> eventIdToEventMap = new Map<Id, Event__c>();
        Set<Id> eventIds = new Set<Id>();
        List<Event__c> eventsToUpdate = new List<Event__c>();
        
        for(Event_Distribution__c ed : newList) {
            if(ed.Event__c != null) {
                eventIds.add(ed.Event__c);
            }
        }
        
        for(Event__c evt : [SELECT Id, Event_Capacity__c FROM Event__c WHERE Id IN :eventIds]) {
            eventIdToEventMap.put(evt.Id, evt);
        }
        
        for(Event_Distribution__c ed : newList) {
            if(eventIdToEventMap.containsKey(ed.Event__c) && eventIdToEventMap.get(ed.Event__c).Event_Capacity__c >= ed.Distribution__c) {
                Event__c evt = eventIdToEventMap.get(ed.Event__c);
                evt.Event_Capacity__c -= ed.Distribution__c;
                eventsToUpdate.add(evt);
            }
            else if(eventIdToEventMap.containsKey(ed.Event__c) && eventIdToEventMap.get(ed.Event__c).Event_Capacity__c < ed.Distribution__c) {
                ed.Status__c = 'Waiting';
            }
        }
        
        if(!eventsToUpdate.isEmpty()) {
            try {
                update eventsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}