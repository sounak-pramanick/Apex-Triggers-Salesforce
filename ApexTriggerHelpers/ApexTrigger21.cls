public class OpportunityLineItemHelper {
    public static void apexTrigger21(List<OpportunityLineItem> newList) {
        Map<Id, Id> oliIdToOppIdMap = new Map<Id, Id>();
        Map<Id, Id> oppIdToAccIdMap = new Map<Id, Id>();
        List<Asset> assetsToInsert = new List<Asset>();
        
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null) {
                oliIdToOppIdMap.put(oli.Id, oli.OpportunityId);
            }
        }
        
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oliIdToOppIdMap.values() AND AccountId != null]) {
            oppIdToAccIdMap.put(opp.Id, opp.AccountId);
        }
        
        for(OpportunityLineItem oli : newList) {
            if(oliIdToOppIdMap.containsKey(oli.Id) && oppIdToAccIdMap.containsKey(oliIdToOppIdMap.get(oli.Id))) {
                Asset newAsset = new Asset();
                newAsset.Name = 'Test Asset - ' + oli.Name;
                newAsset.AccountId = oppIdToAccIdMap.get(oliIdToOppIdMap.get(oli.Id));
                assetsToInsert.add(newAsset);
            }
        }
        
        if(!assetsToInsert.isEmpty()) {
            try {
                insert assetsToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}