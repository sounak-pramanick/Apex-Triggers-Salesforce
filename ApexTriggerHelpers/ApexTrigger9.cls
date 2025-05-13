public class AccountTriggerHelper {
    public static void apexTrigger9(List<Account> newList, Map<Id, Account> oldMap) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for(Opportunity opp : [SELECT Id, StageName, CloseDate, AccountId FROM Opportunity WHERE AccountId IN :newList]) {
            DateTime dt = Date.today();
            DateTime dtBefore30Days = dt.addDays(-30);
            if(opp.StageName != 'Closed Won' && opp.CloseDate < dtBefore30Days) {
                opp.StageName = 'Closed Lost';
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