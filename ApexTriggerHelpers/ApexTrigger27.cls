public class OpportunityTriggerHelper {
    public static void apexTrigger27(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Decimal> accIdToOppAmtMap = new Map<Id, Decimal>();
        List<Account> accsToUpdate = new List<Account>();
        
        if(oldMap == null) {
			for(Opportunity opp : newList) {
				if(opp.Amount != null && opp.AccountId != null) {
					accIds.add(opp.AccountId);
				}
			}
		}
		else {
			for(Opportunity opp : newList) {
				if(opp.Amount != null && opp.Amount != oldMap.get(opp.Id).Amount && opp.AccountId != null) {
					accIds.add(opp.AccountId);
				}
				else if(opp.Amount != null && opp.AccountId != oldMap.get(opp.Id).AccountId && opp.AccountId != null) {
					accIds.add(opp.AccountId);
					accIds.add(oldMap.get(opp.Id).AccountId);
				}
			}
		}
        
        for(AggregateResult aggr : [SELECT SUM(Amount) sum, AccountId FROM Opportunity 
                                    WHERE AccountId IN :accIds AND AccountId != null
                                    GROUP BY AccountId]) {
            accIdToOppAmtMap.put((Id)aggr.get('AccountId'), (Decimal)aggr.get('sum'));
        }
        
        for(Account acc : [SELECT Id, Rating FROM Account WHERE Id IN :accIdToOppAmtMap.keySet()]) {
            Decimal oppAmt = accIdToOppAmtMap.get(acc.Id);
            if(oppAmt > 100000) {
                acc.Rating = 'Hot';
            }
            else if(oppAmt > 50000) {
                acc.Rating = 'Warm';
            }
            else {
                acc.Rating = 'Cold';
            }
            accsToUpdate.add(acc);
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