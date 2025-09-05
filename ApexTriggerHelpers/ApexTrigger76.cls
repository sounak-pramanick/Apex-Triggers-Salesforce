public class DealTriggerHelper {
    public static void apexTrigger76(List<Deal__c> newList, Map<Id, Deal__c> oldMap) {
        Map<Id, Id> dealIdToOpportunityIdMap = new Map<Id, Id>();
        Map<Id, Decimal> oppIdToOppAmountMap = new Map<Id, Decimal>();
        
        for(Deal__c deal : newList) {
            if(oldMap == null) {
                if(deal.Deal_Amount__c != null && deal.Opportunity__c != null) {
                	dealIdToOpportunityIdMap.put(deal.Id, deal.Opportunity__c);
            	}
            }
            else {
                if(deal.Deal_Amount__c != null && deal.Deal_Amount__c != oldMap.get(deal.Id).Deal_Amount__c) {
                    dealIdToOpportunityIdMap.put(deal.Id, deal.Opportunity__c);
                }
                else if(deal.Opportunity__c != null && deal.Opportunity__c != oldMap.get(deal.Id).Opportunity__c) {
                    dealIdToOpportunityIdMap.put(deal.Id, deal.Opportunity__c);
                }
            }
        }
        
        for(Opportunity opp : [SELECT Id, Amount FROM Opportunity WHERE Id IN :dealIdToOpportunityIdMap.values()]) {
            oppIdToOppAmountMap.put(opp.Id, opp.Amount);
        }
        
        for(Deal__c deal : newList) {
            if(deal.Deal_Amount__c != null && deal.Opportunity__c != null && 
               oppIdToOppAmountMap.containsKey(deal.Opportunity__c) && deal.Deal_Amount__c != oppIdToOppAmountMap.get(deal.Opportunity__c)) {
                   deal.addError('Deal amount and related opportunity amount should match');
            }
        }
    }
}