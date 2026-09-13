# CV Review Agent - Salesforce Agentforce

## Overview

CV Review Agent is a Salesforce Agentforce prototype designed to help recruiters review, compare, rank, and shortlist candidates based on role-specific requirements.

The solution allows recruiters to upload candidate CVs, extract structured information using Generative AI, store candidate information in Salesforce, define job requirements using Role Profiles, and evaluate candidates using Agentforce.

The Agent is designed to provide grounded and explainable recommendations using Salesforce data as the source of truth.

In Sales app

The solution supports:

- Multiple CV uploads
- AI-based CV extraction
- Candidate Card generation
- Candidate search and Q&A
- Role-based evaluation
- Candidate scoring
- Candidate comparison
- Candidate ranking
- Missing / uncertain / conflicting information handling
- Candidate bookmarking
- Auditability through Salesforce records

---

## Architecture Overview

The solution is built using:

- Salesforce Platform
- Salesforce Agentforce
- Prompt Builder
- Apex
- Lightning Web Components
- Salesforce Files
- Custom Objects
- Permission Sets

### High-Level Architecture

```text
Recruiter
   |
   v
CV Review Lightning Page
   |
   v
cvUploader LWC
   |
   v
Salesforce Files
ContentDocument
   |
   v
Prompt Builder
CV Candidate Extraction
   |
   v
Structured JSON
   |
   v
CandidateCVProcessor
   |
   v
Candidate__c
   |
   +-----------------------------+
   |                             |
   v                             v
Role_Profile__c              Agentforce
                                  |
                                  v
                          CV Review Agent
                                  |
                +-----------------+-----------------+
                |                 |                 |
                v                 v                 v
        Search Candidates   Get Role Profile   Bookmark Candidate
                |                 |                 |
                +-----------------+-----------------+
                                  |
                                  v
                        Evaluate / Compare / Rank
                                  |
                                  v
                       Candidate_Bookmark__c
```

---

## Project Structure

```text
CV_Review_Agent/
|
├── force-app/
│   └── main/
│       └── default/
│           |
│           ├── classes/
│           │   ├── CVUploadController.cls
│           │   ├── CandidateCVPromptService.cls
│           │   ├── CandidateCVProcessor.cls
│           │   ├── CandidateSearchAction.cls
│           │   ├── RoleProfileSearchAction.cls
│           │   └── CandidateBookmarkAction.cls
│           |
│           ├── lwc/
│           │   └── cvUploader/
│           |
│           ├── objects/
│           │   ├── Candidate__c/
│           │   ├── Candidate_Bookmark__c/
│           │   └── Role_Profile__c/
│           |
│           ├── permissionsets/
│           ├── tabs/
│           └── other Salesforce metadata
│
├── manifest/
├── sfdx-project.json
├── .gitignore
└── README.md
```
