public class OpportunityTriggerHelper {
    public static void apexTrigger26(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        
        for(Opportunity opp : newList) {
            if(oldMap == null) {
                if(opp.StageName == 'Closed Won' && opp.AccountId != null) accIds.add(opp.AccountId);
            }
            else {
                if(opp.StageName == 'Closed Won' && opp.StageName != oldMap.get(opp.Id).StageName && opp.AccountId != null) {
                    accIds.add(opp.AccountId);
                }
                else if(opp.AccountId != null && opp.AccountId != oldMap.get(opp.Id).AccountId) {
                    accIds.add(opp.AccountId);
                    accIds.add(oldMap.get(opp.Id).AccountId);
                }
            }
        }
        
        for(Account acc: [SELECT Id, Account_Status__c, (SELECT StageName FROM Opportunities) FROM Account WHERE Id IN :accIds]) {
            if(!acc.Opportunities.isEmpty()) {
                Boolean isOpen = false;
                for(Opportunity opp : acc.Opportunities) {
                    if(opp.StageName != 'Closed Won') {
                        acc.Account_Status__c = 'Open';
                        accsToUpdate.add(acc);
                        isOpen = true;
                        break;
                    }
                }
                
                if(!isOpen) {
                    acc.Account_Status__c = 'Closed';
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