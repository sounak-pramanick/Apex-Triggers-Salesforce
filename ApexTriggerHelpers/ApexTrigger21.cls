public class OpportunityLineItemHelper {
    public static void apexTrigger21(List<OpportunityLineItem> newList) {
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Id> oppIdToAccIdMap = new Map<Id, Id>();
        List<Asset> assetsToInsert = new List<Asset>();
        
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null) {
                oppIds.add(oli.OpportunityId);
            }
        }
        
        for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds AND AccountId != null]) {
            oppIdToAccIdMap.put(opp.Id, opp.AccountId);
        }
        
        for(OpportunityLineItem oli : newList) {
            if(oli.OpportunityId != null && oppIdToAccIdMap.containsKey(oli.OpportunityId)) {
                Asset newAsset = new Asset();
                newAsset.Name = 'Test Asset - ' + oli.Name;
                newAsset.AccountId = oppIdToAccIdMap.get(oli.OpportunityId);
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