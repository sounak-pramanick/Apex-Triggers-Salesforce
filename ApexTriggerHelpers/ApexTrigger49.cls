public class CandidateTriggerHelper {
    public static void apexTrigger49(List<Candidate__c> newList) {
        Map<String, Id> skillsMap = new Map<String, Id>();
        Set<String> skillsSet = new Set<String>();
        List<Candidate_Skill__c> candidateSkillsToInsert = new List<Candidate_Skill__c>();
        List<Skill__c> skillsToInsert = new List<Skill__c>();
        Map<String, Candidate__c> skillToRemainingCandidatesMap = new Map<String, Candidate__c>();
        
        for(Candidate__c cand : newList) {
            if(String.isNotBlank(cand.Skill_Set__c)) {
                skillsSet.addAll(cand.Skill_Set__c.split(';'));
            }
        }
        
        for(Skill__c skill : [SELECT Id, Name FROM Skill__c WHERE Name IN :skillsSet]) {
            skillsMap.put(skill.Name, skill.Id);
        }
        
        for(Candidate__c cand : newList) {
            if(String.isNotBlank(cand.Skill_Set__c)) {
                for(String skill : cand.Skill_Set__c.split(';')) {
                    if(skillsMap.containsKey(skill)) {
                        Candidate_Skill__c candSkill = new Candidate_Skill__c();
                        candSkill.Candidate__c = cand.Id;
                        candSkill.Skill__c = skillsMap.get(skill);
                        candidateSkillsToInsert.add(candSkill);
                    }
                    else {
                        Skill__c sk = new Skill__c();
                        sk.Name = skill;
                        skillsToInsert.add(sk);
                        skillToRemainingCandidatesMap.put(skill, cand);
                    }
                }
            }
        }
        
        if(!skillsToInsert.isEmpty()) {
            try {
                insert skillsToInsert;
                
                for(Skill__c skill : [SELECT Id, Name FROM Skill__c WHERE Id IN :skillsToInsert]) {
                    Candidate_Skill__c candSkill = new Candidate_Skill__c();
                    candSkill.Candidate__c = skillToRemainingCandidatesMap.get(skill.Name).Id;
                    candSkill.Skill__c = skill.Id;
                    candidateSkillsToInsert.add(candSkill);
                }
                
                if(!candidateSkillsToInsert.isEmpty()) {
                    insert candidateSkillsToInsert;
                }
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
}