class ApexTrigger1 {
	public static void ApexTrigger1(List<Account> newList, Map<Id, Account> oldMap) {
		for(Account acc : newList) {
			if(String.isBlank(acc.Phone)) {
				acc.Phone.addError('You cannot leave the phone field as blank');
			}
		}
	}
}