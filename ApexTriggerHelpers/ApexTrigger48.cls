public class ContactTriggerHelper {
    public static void apexTrigger48(List<Contact> newList) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accIdToOppAmountMap = new Map<Id, Decimal>();
        Map<Id, Account> accIdToAccMap = new Map<Id, Account>();
        List<Account> accsToUpdate = new List<Account>();
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        
        for(Contact con : newList) {
            if(con.AccountId != null) accIds.add(con.AccountId);
        }
        
        for(AggregateResult aggr : [SELECT SUM(Amount) sum, AccountId FROM Opportunity WHERE AccountId IN :accIds GROUP BY AccountId]) {
            accIdToOppAmountMap.put((Id)aggr.get('AccountId'), (Decimal)aggr.get('sum'));
        }
        
        accIdToAccMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accIds]);
        
        for(Contact con : newList) {
            if(con.AccountId != null) {
                if(accIdToOppAmountMap.containsKey(con.AccountId) && accIdToAccMap.containsKey(con.AccountId)) {
                    Account acc = accIdToAccMap.get(con.AccountId);
                    acc.Description = String.valueOf(accIdToOppAmountMap.get(con.AccountId));
                    accsToUpdate.add(acc);
                }
                else {
                    Opportunity opp = new Opportunity();
                    opp.Name = 'Opp from Acc\'s Contact';
                    opp.CloseDate = Date.today();
                    opp.StageName = 'New';
                    opp.AccountId = con.AccountId;
                    oppsToInsert.add(opp);
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
        
        if(!oppsToInsert.isEmpty()) {
            try {
                insert oppsToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}