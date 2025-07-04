public class UserTriggerHelper {
    public static void apexTrigger36(List<User> newList) {
        Set<String> teamSet = new Set<String>();
        Map<String, Id> teamToManagerIdMap = new Map<String, Id>();
        
        for(User usr : newList) {
            if(usr.Assign_Manager__c == true && usr.Team__c != null) teamSet.add(usr.Team__c);
        }
        
        for(User usr : [SELECT Id, Team__c FROM User WHERE Team__c IN :teamSet]) {
            if(!teamToManagerIdMap.containsKey(usr.Team__c)) teamToManagerIdMap.put(usr.Team__c, usr.Id);
        }
        
        for(User usr : newList) {
            if(usr.Assign_Manager__c == true && usr.Team__c != null) {
                if(teamToManagerIdMap.containsKey(usr.Team__c)) {
                    usr.ManagerId = teamToManagerIdMap.get(usr.Team__c);
                }
                else {
                    usr.addError('No user is present for the selected team');
                }
            }
        }
    }
}