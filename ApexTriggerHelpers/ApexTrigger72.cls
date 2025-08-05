public class AccountTriggerHelper {
    public static void apexTrigger72(List<Account> newList, Map<Id, Account> oldMap) {
        for(Account acc : newList) {
            if(oldMap != null && (oldMap.get(acc.Id).LastModifiedDate.addHours(1) > System.now())) {
                acc.addError('Account cannot be updated within an hour');
            }
        }
    }
}