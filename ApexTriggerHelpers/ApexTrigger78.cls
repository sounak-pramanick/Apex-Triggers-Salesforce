public class AccountTriggerHelper {
    public static void apexTrigger78(List<Account> newList, Map<Id, Account> oldMap) {
        for(Account acc : newList) {
	   if(oldMap != null) {
                Id currentUserId = UserInfo.getUserId();
                Long diff = DateTime.now().getTime() - acc.LastModifiedDate.getTime();
                Decimal diffHours = (Decimal) diff / (1000*60*60);
		if(acc.LastModifiedById == currentUserId && diffHours < 1) {
			acc.addError('You can modify this account only once every hour');
		}
	    }
	}
    }
}