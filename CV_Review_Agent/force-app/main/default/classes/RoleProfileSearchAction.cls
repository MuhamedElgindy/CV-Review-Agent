public with sharing class RoleProfileSearchAction {

    public class Request {

        @InvocableVariable(
            label='Role Name'
            description='Name of the role profile to search for.'
            required=true
        )
        public String roleName;
    }

    public class Response {

        @InvocableVariable(
            label='Role Profile Data'
            description='Structured role requirements returned from Salesforce.'
        )
        public String roleProfileData;
    }

    @InvocableMethod(
        label='Get Role Profile'
        description='Searches Salesforce for an active Role Profile and returns its requirements.'
    )
    public static List<Response> getRoleProfile(
        List<Request> requests
    ) {

        List<Response> responses = new List<Response>();

        for (Request request : requests) {

            Response response = new Response();

            if (
                request == null ||
                String.isBlank(request.roleName)
            ) {
                response.roleProfileData =
                    'Role name is required.';

                responses.add(response);
                continue;
            }

            List<Role_Profile__c> roles = [
                SELECT
                    Id,
                    Name,
                    Required_Skills__c,
                    Minimum_Experience_Years__c,
                    Preferred_Skills__c,
                    Education_Requirements__c,
                    Additional_Requirements__c,
                    Active__c
                FROM Role_Profile__c
                WHERE Name LIKE :('%' + request.roleName + '%')
                AND Active__c = true
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (roles.isEmpty()) {

                response.roleProfileData =
                    'No active Role Profile found for: ' +
                    request.roleName;

                responses.add(response);
                continue;
            }

            Role_Profile__c role = roles[0];

            Map<String, Object> result =
                new Map<String, Object>();

            result.put(
                'roleProfileId',
                role.Id
            );

            result.put(
                'roleName',
                role.Name
            );

            result.put(
                'requiredSkills',
                role.Required_Skills__c
            );

            result.put(
                'minimumExperienceYears',
                role.Minimum_Experience_Years__c
            );

            result.put(
                'preferredSkills',
                role.Preferred_Skills__c
            );

            result.put(
                'educationRequirements',
                role.Education_Requirements__c
            );

            result.put(
                'additionalRequirements',
                role.Additional_Requirements__c
            );

            result.put(
                'active',
                role.Active__c
            );

            response.roleProfileData =
                JSON.serialize(result);

            responses.add(response);
        }

        return responses;
    }
}