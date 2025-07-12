public class OrderTriggerHelper {
    public static void apexTrigger60(List<Order__c> newList, Map<Id, Order__c> oldMap) {
        for(Order__c order : newList) {
            if(oldMap != null && order.Stage__c != oldMap.get(order.Id).Stage__c) {
                DateTime lastStageChange = order.Last_Stage_Change__c;
                if(lastStageChange == null) {
                    lastStageChange = order.CreatedDate;
                }
                Double dateDiff = (Datetime.now().getTime() - lastStageChange.getTime()) / 1000;
                if(String.isBlank(order.Stage_History__c)) order.Stage_History__c = '';
                order.Stage_History__c += '\nThe order was updated from stage \'' + oldMap.get(order.Id).Stage__c + 
                    				      '\' to stage \'' + order.Stage__c + '\' after time ' + dateDiff + ' seconds.';
                order.Last_Stage_Change__c = Datetime.now();
            }
        }
    }
}