public class UserTriggerHelper {
    public static void apexTrigger40(List<User> newList, Map<Id, User> oldMap) {
        Map<Id, Id> userIdToManagerIdMap = new Map<Id, Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for(User usr : newList) {
            if(oldMap != null && usr.IsActive == false && usr.IsActive != oldMap.get(usr.Id).IsActive && usr.ManagerId != null) {
                userIdToManagerIdMap.put(usr.Id, usr.ManagerId);
            }
        }
        
        for(Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE IsClosed = false AND OwnerId IN :userIdToManagerIdMap.keySet()]) {
            opp.OwnerId = userIdToManagerIdMap.get(opp.OwnerId);
            oppsToUpdate.add(opp);
        }
        
        if(!oppsToUpdate.isEmpty()) {
            try {
                update oppsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}