public class ContactTriggerHelper {
    public static void apexTrigger13(List<Contact> newList, Map<Id, Contact> oldMap) {
        // Below code for scenario when both phone and contact are duplicate
        /*
        Set<String> conEmailSet = new Set<String>();
        Set<String> conPhoneSet = new Set<String>();
        Map<String, Contact> existingConMap = new Map<String, Contact>();
        Set<String> existingCons = new Set<String>();
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.Email != null) {
                	conEmailSet.add(con.Email);
            	}
            	if(con.Phone != null) {
                	conPhoneSet.add(con.Phone);
            	}
            }
            else {
                if(con.Email != null && con.Email != oldMap.get(con.Id).Email) {
                	conEmailSet.add(con.Email);
            	}
                if(con.Phone != null && con.Phone != oldMap.get(con.Id).Phone) {
                	conPhoneSet.add(con.Phone);
            	}
            }
        }
        
        for(Contact con : [SELECT Id, Email, Phone FROM Contact WHERE Email IN :conEmailSet OR Phone IN :conPhoneSet]) {
            existingConMap.put(con.Email + '-' + con.Phone, con);
        }
        
        for(Contact con : newList) {
            if(con.Email != null && con.Phone != null && existingConMap.containsKey(con.Email + '-' + con.Phone)) {
                con.addError('Duplicate contact with same email and phone present');
            }
            else if(con.Email != null && con.Phone != null && existingCons.contains(con.Email + '-' + con.Phone)) {
                con.addError('Duplicate contact with same email and phone present');
            }
            else {
                existingCons.add(con.Email + '-' + con.Phone);
            }
        }
		*/
        
        // Below code for scenario when either phone or contact or both are duplicate
        Set<String> conEmailSet = new Set<String>();
        Set<String> conPhoneSet = new Set<String>();
        Map<String, Contact> duplicateEmailConMap = new Map<String, Contact>();
        Map<String, Contact> duplicatePhoneConMap = new Map<String, Contact>();
        Map<String, Contact> existingConMap = new Map<String, Contact>();
        Set<String> existingCons = new Set<String>();
        String errorMsg = '';
        
        for(Contact con : newList) {
            if(oldMap == null) {
                if(con.Email != null) {
                	conEmailSet.add(con.Email);
            	}
            	if(con.Phone != null) {
                	conPhoneSet.add(con.Phone);
            	}
            }
            else {
                if(con.Email != null && con.Email != oldMap.get(con.Id).Email) {
                	conEmailSet.add(con.Email);
            	}
                if(con.Phone != null && con.Phone != oldMap.get(con.Id).Phone) {
                	conPhoneSet.add(con.Phone);
            	}
            }
        }
        
        for(Contact con : [SELECT Id, Email, Phone FROM Contact WHERE Email IN :conEmailSet OR Phone IN :conPhoneSet]) {
            duplicateEmailConMap.put(con.Email, con);
            duplicatePhoneConMap.put(con.Phone, con);
        }
    }
}