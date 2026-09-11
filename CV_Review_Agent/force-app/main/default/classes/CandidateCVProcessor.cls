public with sharing class CandidateCVProcessor {

    public class CandidateExtractionResult {
        public String fullName;
        public String email;
        public String phone;
        public String skills;
        public Decimal experienceYears;
        public String experienceSummary;
        public String education;
        public String achievements;
        public String missingInformation;
        public String uncertainInformation;
        public String conflictingInformation;
    }

    @AuraEnabled
    public static void updateCandidateFromJson(
        Id candidateId,
        String extractionJson
    ) {

        if (candidateId == null) {
            throw new AuraHandledException('Candidate Id is required.');
        }

        if (String.isBlank(extractionJson)) {
            throw new AuraHandledException('Extraction JSON is required.');
        }

        CandidateExtractionResult result;

        try {
            result = (CandidateExtractionResult)
                JSON.deserialize(
                    extractionJson,
                    CandidateExtractionResult.class
                );
        } catch (Exception e) {
            throw new AuraHandledException(
                'Invalid extraction JSON: ' + e.getMessage()
            );
        }

        Candidate__c candidate = [
            SELECT Id
            FROM Candidate__c
            WHERE Id = :candidateId
            LIMIT 1
        ];

        if (!String.isBlank(result.fullName)) {
            candidate.Name = result.fullName;
        }

        candidate.Email__c = result.email;
        candidate.Phone__c = result.phone;
        candidate.Skills__c = result.skills;
        candidate.Experience_Years__c = result.experienceYears;
        candidate.Experience_Summary__c = result.experienceSummary;
        candidate.Education__c = result.education;
        candidate.Achievements__c = result.achievements;
        candidate.Missing_Information__c = result.missingInformation;
        candidate.Uncertain_Information__c = result.uncertainInformation;
        candidate.Conflicting_Information__c = result.conflictingInformation;

        update candidate;
    }
}