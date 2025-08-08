public class AccountTriggerHelper {
    public static void apexTrigger75(List<Account> oldList) {
        Map<Id, Contact> accIdToPotentialBuyerConMap = new Map<Id, Contact>();
        
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :oldList AND Potential_Buyer__c = true]) {
            accIdToPotentialBuyerConMap.put(con.AccountId, con);
        }
        
        for(Account acc : oldList) {
            if(accIdToPotentialBuyerConMap.containsKey(acc.Id)) {
                acc.addError('Account cannot be deleted since it has contact(s) which is/are potential buyers');
            }
        }
    }
}