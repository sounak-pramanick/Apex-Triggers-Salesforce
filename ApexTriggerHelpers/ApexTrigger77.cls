public class MarketplaceTriggerHelper {
    public static void apexTrigger77(List<Marketplace__c> newList, Map<Id, Marketplace__c> oldMap) {
        Map<Id, String> assetIdToMarketplaceNameMap = new Map<Id, String>();
        Map<Id, Id> accountIdToAssetIdMap = new Map<Id, Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Marketplace__c mp : newList) {
            if(oldMap == null) {
                if(mp.Asset__c != null) {
                    assetIdToMarketplaceNameMap.put(mp.Asset__c, mp.Name);
                }
            }
            else {
                if(mp.Asset__c != null && mp.Asset__c != oldMap.get(mp.Id).Asset__c) {
                    assetIdToMarketplaceNameMap.put(mp.Asset__c, mp.Name);
                    assetIdToMarketplaceNameMap.put(oldMap.get(mp.Id).Asset__c, mp.Name);
                }
            }
        }
        
        for(Asset asset : [SELECT Id, AccountId FROM Asset WHERE Id IN :assetIdToMarketplaceNameMap.keySet() AND AccountId != null]) {
            accountIdToAssetIdMap.put(asset.AccountId, asset.Id);
        }
        
        for(Account acc : [SELECT Id, Active_Marketplace__c FROM Account WHERE Id IN :accountIdToAssetIdMap.keySet()]) {
            if(accountIdToAssetIdMap.containsKey(acc.Id)) {
                Id assetId = accountIdToAssetIdMap.get(acc.Id);
                
                if(assetIdToMarketplaceNameMap.containsKey(assetId)) {
                    String marketplaceName = assetIdToMarketplaceNameMap.get(assetId);
                    
                    if(String.isNotBlank(acc.Active_Marketplace__c) && acc.Active_Marketplace__c.contains(marketplaceName)) {
                        acc.Active_Marketplace__c = acc.Active_Marketplace__c.replace(marketplaceName, '');
                    }
                    else {
                        if(String.isBlank(acc.Active_Marketplace__c)) acc.Active_Marketplace__c = marketplaceName;
                        else acc.Active_Marketplace__c += ' ' + marketplaceName;
                    }
                    /*if(acc.Active_Marketplace__c.endsWith(',')) {
                        String content = acc.Active_Marketplace__c;
                        content = content.substring(0, acc.Active_Marketplace__c.length() - 1);
                        acc.Active_Marketplace__c = content;
                    }*/
                    accsToUpdate.add(acc);
                }
            }
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