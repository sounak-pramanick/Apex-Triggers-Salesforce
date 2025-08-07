public class Patient_TriggerHelper {
    public static void apexTrigger66(List<Patient__c> newList) {
        Map<Id, String> patientIdToPriorityMap = new Map<Id, String>();
        Map<String, List<Bed__c>> bedCategoryToBedIdMap = new Map<String, List<Bed__c>>();
        List<Bed__c> bedsToUpdate = new List<Bed__c>();
        List<Waiting_List__c> waitingListToInsert = new List<Waiting_List__c>();
        
        for(Patient__c patient : newList) {
            if(patient.Admission_Status__c == 'Waiting') {
                patientIdToPriorityMap.put(patient.Id, patient.Priority__c);
            }
        }
        
        for(Bed__c bed : [SELECT Id, Category__c, Status__c FROM Bed__c WHERE Category__c IN :patientIdToPriorityMap.values() AND
                         Status__c = 'Available']) {
            if(!bedCategoryToBedIdMap.containsKey(bed.Category__c)) {
                bedCategoryToBedIdMap.put(bed.Category__c, new List<Bed__c>());
            }
			bedCategoryToBedIdMap.get(bed.Category__c).add(bed);
        }
        
        for(Patient__c patient : newList) {
            if(patient.Admission_Status__c == 'Waiting' && bedCategoryToBedIdMap.containsKey(patient.Priority__c)) {
                List<Bed__c> bedList = bedCategoryToBedIdMap.get(patient.Priority__c);
                if(bedList[0].Status__c == 'Available') {
                    patient.Assigned_Bed__c = bedList[0].Id;
                    patient.Admission_Status__c = 'Admitted';
                    bedList[0].Status__c = 'Occupied';
                	bedsToUpdate.add(bedList[0]);
                }
            }
            else if(patient.Admission_Status__c == 'Waiting' && !bedCategoryToBedIdMap.containsKey(patient.Priority__c)) {
                Waiting_List__c wl = new Waiting_List__c();
                wl.Name = 'Waiting List - ' + patient.Name;
                wl.Patient__c = patient.Id;
                waitingListToInsert.add(wl);
            }
        }
        
        if(!bedsToUpdate.isEmpty()) {
            try {
                update bedsToUpdate;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        
        if(!waitingListToInsert.isEmpty()) {
            try {
                insert waitingListToInsert;
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}