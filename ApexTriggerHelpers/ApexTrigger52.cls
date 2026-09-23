public class OpportunityTriggerHelper {
    public static void apexTrigger52(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> ownerIds = new Set<Id>();
        List<Opportunity> opps = new List<Opportunity>();
        Map<Id, User> userMap;
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        if(oldMap == null) {
			for(Opportunity opp : newList) {
				if(opp.Amount > 10000 && opp.OwnerId != null) {
					ownerIds.add(opp.OwnerId);
					opps.add(opp);
				}
			}
		}
		else {
			for(Opportunity opp : newList) {
				if(opp.Amount != oldMap.get(opp.Id).Amount && opp.Amount > 10000 && opp.OwnerId != null) {
					ownerIds.add(opp.OwnerId);
					opps.add(opp);
				}
			}
		}

		userMap = new Map<Id, User>([Select Id, Email from User where Id IN :ownerIds]);

		for(Opportunity opp : opps) {
			sendEmail(opp, emailList, userMap);
		}

		if(!emailList.isEmpty()) {
			try {
				Messaging.sendEmail(emailList);
			}
			catch(Exception e) {
                System.debug(e.getMessage());
			}
		}
    }

    private static void sendEmail(Opportunity opp, List<Messaging.SingleEmailMessage> emailList, Map<Id, User> userMap) {
		String emailAddress = '';
		if(userMap.containsKey(opp.OwnerId)) {
			emailAddress = userMap.get(opp.OwnerId).Email;
		}
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.setTargetObjectId(opp.OwnerId);
		email.setToAddresses(new String[]{emailAddress});
		email.setSubject('Opportunity ' + opp.Name + ' has been updated');
		email.setPlainTextBody('Opportunity ' + opp.Name + ' with amount ' + opp.Amount + ' has been updated');
		emailList.add(email);
	}
}