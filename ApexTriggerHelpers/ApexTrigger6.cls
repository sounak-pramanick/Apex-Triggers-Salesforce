public class AccountTriggerHelper {
    public static void apexTrigger6(List<Account> newList, Map<Id, Account> oldMap) {
        List<String> accNames = new List<String>();
        List<String> existingAccNames = new List<String>();
        Set<String> processedAccNames = new Set<String>();
        
        for(Account acc : newList) {
            if(oldMap == null) {
                accNames.add(acc.Name);
            }
            else {
                if(acc.Name != oldMap.get(acc.Id).Name) {
                    accNames.add(acc.Name);
                }
            }
        }
        
        for(Account acc : [SELECT Id, Name FROM Account WHERE Name IN :accNames]) {
            existingAccNames.add(acc.Name);
        }
        
        for(Account acc : newList) {
            if(existingAccNames.contains(acc.Name)) {
                acc.addError('Duplicate account with same name already present');
            }
            else if(processedAccNames.contains(acc.Name)) {
                acc.addError('Duplicate account with same name already present');
            }
            else {
                processedAccNames.add(acc.Name);
            }
        }
    }
}