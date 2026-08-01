public class CaseTriggerHelper {
    /*
    public static void apexTrigger31(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accIdToClosedCaseCount = new Map<Id, Integer>();
        List<Account> accsToUpdate = new List<Account>();
        
        if(oldMap == null) {
			if(cs.Status == 'Closed' && cs.AccountId != null) {
				accIds.add(cs.AccountId);
			}
		}
		else {
			for(Case cs : newList) {
				// current case is updated to closed from open
				if(cs.Status == 'Closed' && cs.Status != oldMap.get(cs.Id).Status && cs.AccountId != null) {
					accIds.add(cs.AccountId);
				}
				// current case is updated to open from closed, then also closed case count changes
				else if(cs.Status != 'Closed' && oldMap.get(cs.Id).Status == 'Closed' && cs.AccountId != null) {
					accIds.add(cs.AccountId);
				}
				// current case is updated to closed and account id is updated, then also closed case count changes for both new and old accounts
				else if(cs.Status == 'Closed' && cs.AccountId != null && cs.AccountId != oldMap.get(cs.Id).AccountId) {
					accIds.add(cs.AccountId);
					accIds.add(oldMap.get(cs.Id).AccountId);
				}
			}
		}

		if(accIds.isEmpty) return;
        
        for(AggregateResult aggr : [SELECT COUNT(Id) co, AccountId 
                                    FROM Case WHERE AccountId IN :accIds AND Status = 'Closed' 
                                    GROUP BY AccountId]){
            if(!accIdToClosedCaseCount.containsKey((Id)aggr.get('AccountId'))) {
                accIdToClosedCaseCount.put((Id)aggr.get('AccountId'), (Integer)aggr.get('co'));
            }
        }
        
        for(Account acc : [SELECT Id, Rating FROM Account WHERE Id IN :accIdToClosedCaseCount.keySet()]) {
            if(accIdToClosedCaseCount.containsKey(acc.Id)) {
                Integer closedCaseCount = accIdToClosedCaseCount.get(acc.Id);
                if(closedCaseCount > 5) {
                    acc.Rating = 'Hot';
                }
                else if(closedCaseCount > 2) {
                    acc.Rating = 'Warm';
                }
                else {
                    acc.Rating = 'Cold';
                }
                accsToUpdate.add(acc);
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
    */

    // alternative approach without aggregate query
    public static void apexTrigger31(List<Case> newList, Map<Id, Case> oldMap) {
        Set<Id> accIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();

        if(oldMap == null) {
            for(Case cs : newList) {
                // case created with closed status
                if(cs.Status == 'Closed' && cs.AccountId != null) {
				    accIds.add(cs.AccountId);
			    }
            }
		}
		else {
			for(Case cs : newList) {
				// current case is updated to closed from open
				if(cs.Status == 'Closed' && cs.Status != oldMap.get(cs.Id).Status && cs.AccountId != null) {
					accIds.add(cs.AccountId);
				}
				// current case is updated to open from closed, then also closed case count changes
				else if(cs.Status != 'Closed' && oldMap.get(cs.Id).Status == 'Closed' && cs.AccountId != null) {
					accIds.add(cs.AccountId);
				}
				// current case is updated to closed and account id is updated, then also closed case count changes for both new and old accounts
				else if(cs.Status == 'Closed' && cs.AccountId != null && cs.AccountId != oldMap.get(cs.Id).AccountId) {
					accIds.add(cs.AccountId);
					if(oldMap.get(cs.Id).AccountId != null) {
                        accIds.add(oldMap.get(cs.Id).AccountId);
                    }
				}
			}
		}

		if(accIds.isEmpty()) return;

		for(Account acc : [SELECT Id, Rating, (SELECT Id FROM Cases WHERE Status = 'Closed') FROM Account WHERE Id IN :accIds]) {
			List<Case> closedCases = acc.Cases;

			if(closedCases.length > 5) {
                acc.Rating = 'Hot';
            }
			else if(closedCases.length > 2) {
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