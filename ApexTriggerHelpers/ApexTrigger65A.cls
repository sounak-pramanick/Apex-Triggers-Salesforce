public class LeadTriggerHelper {
    public static void apexTrigger65A(List<Lead> newList, Map<Id, Lead> oldMap) {
        /*
         * On lead object if email is present check contact with same email, if there is no contact then create contact with same email 
         * and link with lead where lead is having contactId as field. 
         * If Email is already present then assign that contact with the same Lead. (found in comment on trigger 65)
         * Lead - 
         *    email present - 
         * 		contact with same email present - link with lead's contactid
         * 		contact with same email not present - create con & link with lead's contactid
		*/
        
        Map<Id, String> leadIdToLeadEmailMap = new Map<Id, String>();
        Map<String, Contact> conEmailToConMap = new Map<String, Contact>();
        Map<String, Lead> leadEmailsToLeadsToUpdateMap = new Map<String, Lead>();
        List<Contact> consToInsert = new List<Contact>();
        
        for(Lead lead : newList) {
			if(oldMap != null) {
				if(String.isNotBlank(lead.Email) && String.isBlank(oldMap.get(lead.Id).Email)) {
					leadIdToLeadEmailMap.put(lead.Id, lead.Email);
				}
			}
			else {
				if(String.isNotBlank(lead.Email)) {
					leadIdToLeadEmailMap.put(lead.Id, lead.Email);
				}
			}
		}

		for(Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :leadIdToLeadEmailMap.values()]) {
			conEmailToConMap.put(con.Email, con);
		}

		for(Lead lead : newList) {
			if(oldMap != null) {
				if(String.isNotBlank(lead.Email) && String.isBlank(oldMap.get(lead.Id).Email)) {
					if(conEmailToConMap.containsKey(lead.Email)) {
						lead.Contact_Id__c = conEmailToConMap.get(lead.Email).Id;
					}
					else {
						Contact con = new Contact(LastName='Test Con from Lead', Email=lead.Email);
						consToInsert.add(con);
						leadEmailsToLeadsToUpdateMap.put(lead.Email, lead);
					}
				}
			}
			else {
				if(String.isNotBlank(lead.Email)) {
					if(conEmailToConMap.containsKey(lead.Email)) {
						lead.Contact_Id__c = conEmailToConMap.get(lead.Email).Id;
					}
					else {
						Contact con = new Contact(LastName='Test Con from Lead', Email=lead.Email);
						consToInsert.add(con);
						leadEmailsToLeadsToUpdateMap.put(lead.Email, lead);
					}
				}
			}
		}

		if(!consToInsert.isEmpty()) {
            try {
                insert consToInsert;

				for(Contact con : consToInsert) {
					if(leadEmailsToLeadsToUpdateMap.containsKey(con.Email)) {
						Lead lead = leadEmailsToLeadsToUpdateMap.get(con.Email);
						lead.Contact_Id__c = con.Id;
					}
				}
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
		}
    }
}