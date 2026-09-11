public with sharing class CandidateCVPromptService {

    private static final String PROMPT_TEMPLATE_API_NAME =
        'CV_Candidate_Extraction';

    /**
     * Sends the actual Salesforce File (ContentDocument)
     * to Prompt Builder and returns the generated JSON.
     */
    public static String extractCandidateFromFile(
        Id contentDocumentId
    ) {

        if (contentDocumentId == null) {
            throw new AuraHandledException(
                'Content Document Id is required.'
            );
        }

        try {

            /*
             * Flex Prompt Salesforce Object inputs are passed
             * as a record reference containing the record Id.
             *
             * Our Prompt input:
             * Name     = CV File
             * API Name = CV_File
             * Object   = ContentDocument
             */
            Map<String, String> fileRecord =
                new Map<String, String>();

            fileRecord.put(
                'id',
                String.valueOf(contentDocumentId)
            );

            ConnectApi.WrappedValue fileValue =
                new ConnectApi.WrappedValue();

            fileValue.value = fileRecord;

            Map<String, ConnectApi.WrappedValue> inputParams =
                new Map<String, ConnectApi.WrappedValue>();

            inputParams.put(
                'Input:CV_File',
                fileValue
            );

            /*
             * Prompt execution configuration.
             */
            ConnectApi.EinsteinPromptTemplateGenerationsInput input =
                new ConnectApi.EinsteinPromptTemplateGenerationsInput();

            input.additionalConfig =
                new ConnectApi.EinsteinLlmAdditionalConfigInput();

            input.additionalConfig.applicationName =
                'PromptBuilderPreview';

            input.isPreview = false;
            input.inputParams = inputParams;

            /*
             * Execute the activated Prompt Template.
             */
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation output =
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                    PROMPT_TEMPLATE_API_NAME,
                    input
                );

            if (
                output == null ||
                output.generations == null ||
                output.generations.isEmpty()
            ) {
                throw new AuraHandledException(
                    'CV extraction returned no response.'
                );
            }

            String resultJson =
                output.generations[0].text;

            if (String.isBlank(resultJson)) {
                throw new AuraHandledException(
                    'CV extraction response is empty.'
                );
            }

            return cleanJsonResponse(resultJson);

        } catch (Exception e) {

            System.debug(
                LoggingLevel.ERROR,
                'CV File Prompt Error: ' + e.getMessage()
            );

            System.debug(
                LoggingLevel.ERROR,
                e.getStackTraceString()
            );

            throw e;
        }
    }


    /**
     * Full processing flow:
     *
     * ContentDocument
     *      ↓
     * Prompt Builder
     *      ↓
     * JSON
     *      ↓
     * CandidateCVProcessor
     *      ↓
     * Candidate__c update
     */
    public static void processCandidateCV(
        Id candidateId,
        Id contentDocumentId
    ) {

        if (candidateId == null) {
            throw new AuraHandledException(
                'Candidate Id is required.'
            );
        }

        String extractionJson =
            extractCandidateFromFile(
                contentDocumentId
            );

        CandidateCVProcessor.updateCandidateFromJson(
            candidateId,
            extractionJson
        );
    }


    /**
     * Defensive cleanup in case the model wraps
     * the JSON with markdown code fences.
     */
    private static String cleanJsonResponse(
        String value
    ) {

        String cleaned = value.trim();

        if (cleaned.startsWith('```json')) {
            cleaned = cleaned.substring(7);
        }
        else if (cleaned.startsWith('```')) {
            cleaned = cleaned.substring(3);
        }

        if (cleaned.endsWith('```')) {
            cleaned = cleaned.substring(
                0,
                cleaned.length() - 3
            );
        }

        return cleaned.trim();
    }
}