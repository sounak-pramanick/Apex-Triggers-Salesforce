public class AccountTriggerHelper {
    public static void apexTrigger18(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for(Account acc : newList) {
            if(acc.Close_All_Opportunities__c && oldMap != null && 
               acc.Close_All_Opportunities__c != oldMap.get(acc.Id).Close_All_Opportunities__c) {
                accIds.add(acc.Id);
            }
        }
        
        for(Opportunity opp : [SELECT Id, StageName, Probability, IsClosed, AccountId FROM Opportunity WHERE AccountId IN :accIds]) {
            if(opp.Probability != null && opp.Probability >= 70 && !opp.IsClosed) {
                opp.StageName = 'Closed Won';
                oppsToUpdate.add(opp);
            }
        }
        
        if(!oppsToUpdate.isEmpty()) {
            try {
                update oppsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }    
    }
}