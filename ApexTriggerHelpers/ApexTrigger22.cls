public class OpportunityLineItemHelper {
    public static void apexTrigger22(List<OpportunityLineItem> newList) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Map<Id, String> oliIdToOppProductFamilyMap = new Map<Id, String>();
        Map<Id, String> oliIdToProductFamilyMap = new Map<Id, String>();
        Map<Id, Opportunity> oppMap;
        Map<Id, Product2> productMap;
        
        for(OpportunityLineItem oli : newList) {
            if(oli.Product2Id != null && oli.OpportunityId != null) {
                productIds.add(oli.Product2Id);
                oppIds.add(oli.OpportunityId);
            }
        }
        
        oppMap = new Map<Id, Opportunity>([SELECT Id, Product_Family__c FROM Opportunity WHERE Id IN :oppIds]);
        productMap = new Map<Id, Product2>([SELECT Id, Family FROM Product2 WHERE Id IN :productIds]);
        
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null && oppMap.containsKey(oli.OpportunityId) &&
              oli.Product2Id != null && productMap.containsKey(oli.Product2Id) && 
               oppMap.get(oli.OpportunityId).Product_Family__c != productMap.get(oli.Product2Id).Family) {
                   oli.addError('The Opportunity Product Family and Product Family should be same');
               }
        }
    }
}