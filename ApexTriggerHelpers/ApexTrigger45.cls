public class CaseTriggerHelper {
    public static void apexTrigger45(List<Case> newList) {
        Set<String> emailIds = new Set<String>();
        Map<String, Id> conEmailToConIdMap = new Map<String, Id>();
        Map<String, Contact> newConEmailToConMap = new Map<String, Contact>();
        List<Contact> consToInsert = new List<Contact>();
        
        for(Case cs : newList) {
            if(cs.SuppliedEmail != null) emailIds.add(cs.SuppliedEmail);
        }
        
        for(Contact con : [SELECT Id, Email FROM Contact WHERE Email IN :emailIds]) {
            conEmailToConIdMap.put(con.Email, con.Id);
        }
        
        for(Case cs : newList) {
            if(cs.SuppliedEmail != null && conEmailToConIdMap.containsKey(cs.SuppliedEmail)) {
                cs.ContactId = conEmailToConIdMap.get(cs.SuppliedEmail);
            }
            else if(cs.SuppliedEmail != null && !conEmailToConIdMap.containsKey(cs.SuppliedEmail)) {
                Contact con = new Contact();
                con.FirstName = 'New';
                con.LastName = 'Con Created From Case';
                con.Email = cs.SuppliedEmail;
                consToInsert.add(con);
                newConEmailToConMap.put(con.Email, con);
            }
        }
        
        if(!consToInsert.isEmpty()) {
            try {
                insert consToInsert;
                
                for(Case cs : newList) {
                    if(cs.SuppliedEmail != null && newConEmailToConMap.containsKey(cs.SuppliedEmail)) {
                        cs.ContactId = newConEmailToConMap.get(cs.SuppliedEmail).Id;
                    }
                }
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}