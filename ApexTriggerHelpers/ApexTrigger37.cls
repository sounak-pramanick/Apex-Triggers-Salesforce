public class OpportunityContactRoleTriggerHelper {
    public static void apexTrigger37(List<OpportunityContactRole> newList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Opportunity> oppMap;
        
        for(OpportunityContactRole ocr : newList) {
            if(ocr.OpportunityId != null) {
                oppIds.add(ocr.OpportunityId);
            }
        }
        
        oppMap = new Map<Id, Opportunity>([SELECT Id, IsClosed, (SELECT Id FROM OpportunityContactRoles) FROM Opportunity WHERE Id IN :oppIds]);
        
        for(OpportunityContactRole ocr : newList) {
            if(ocr.OpportunityId != null && oppMap.containsKey(ocr.OpportunityId) && oppMap.get(ocr.OpportunityId).IsClosed) {
                ocr.addError('OpportunityContactRole cannot be inserted on closed Opportunity');
            }
            else if(ocr.OpportunityId != null && oppMap.containsKey(ocr.OpportunityId)) {
                if(!oppMap.get(ocr.OpportunityId).OpportunityContactRoles.isEmpty()) {
                    ocr.addError('Opportunity already contains an OpportunityContactRole');
                }
            }
        }
    }
}