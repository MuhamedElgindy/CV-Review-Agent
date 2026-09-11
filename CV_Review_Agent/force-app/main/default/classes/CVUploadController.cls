public with sharing class CVUploadController {

    @AuraEnabled
    public static Id createCandidateFromUploadedFile(
        String fileName,
        String contentDocumentId
    ) {

        if (String.isBlank(fileName)) {
            throw new AuraHandledException(
                'File name is required.'
            );
        }

        if (String.isBlank(contentDocumentId)) {
            throw new AuraHandledException(
                'Content Document Id is required.'
            );
        }

        Id documentId;

        try {
            documentId = (Id) contentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException(
                'Invalid Content Document Id.'
            );
        }

        try {

            /*
             * STEP 1
             * The file is already stored in Salesforce Files
             * by lightning-file-upload.
             *
             * Call Prompt Builder BEFORE doing any DML here.
             */
            String extractionJson =
                CandidateCVPromptService.extractCandidateFromFile(
                    documentId
                );

            if (String.isBlank(extractionJson)) {
                throw new AuraHandledException(
                    'AI extraction returned an empty response.'
                );
            }


            /*
             * STEP 2
             * Create Candidate only after AI extraction succeeds.
             */
            Candidate__c candidate =
                new Candidate__c(
                    Name = 'Pending - ' + fileName,
                    Source_File_Name__c = fileName
                );

            insert candidate;


            /*
             * STEP 3
             * Link the uploaded Salesforce File
             * to the new Candidate.
             */
            ContentDocumentLink fileLink =
                new ContentDocumentLink(
                    ContentDocumentId = documentId,
                    LinkedEntityId = candidate.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                );

            insert fileLink;


            /*
             * STEP 4
             * Parse the AI JSON and populate Candidate__c.
             */
            CandidateCVProcessor.updateCandidateFromJson(
                candidate.Id,
                extractionJson
            );


            return candidate.Id;

        } catch (Exception e) {

            System.debug(
                LoggingLevel.ERROR,
                'CV PROCESSING ERROR = ' +
                e.getMessage()
            );

            System.debug(
                LoggingLevel.ERROR,
                'CV PROCESSING STACK TRACE = ' +
                e.getStackTraceString()
            );

            throw new AuraHandledException(
                'CV AI processing failed: ' +
                e.getMessage()
            );
        }
    }
}