public class AccountTriggerHelper {
    public static void apexTrigger10(List<Account> oldList) {
        for(Account acc : oldList) {
            if(acc.Active_Account__c == true) {
                acc.addError('Active account cannot be deleted');
            }
        }
    }
}