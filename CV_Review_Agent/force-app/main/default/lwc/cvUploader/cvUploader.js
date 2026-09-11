import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import createCandidateFromUploadedFile
    from '@salesforce/apex/CVUploadController.createCandidateFromUploadedFile';

export default class CvUploader extends LightningElement {

    processing = false;
    processedFiles = [];

    get hasProcessedFiles() {
        return this.processedFiles.length > 0;
    }

    async handleUploadFinished(event) {

        const uploadedFiles = event.detail.files;

        if (!uploadedFiles || uploadedFiles.length === 0) {
            return;
        }

        this.processing = true;

        const successfulFiles = [];
        const failedFiles = [];

        try {

            for (const file of uploadedFiles) {

                try {

                    const candidateId =
                        await createCandidateFromUploadedFile({
                            fileName: file.name,
                            contentDocumentId: file.documentId
                        });

                    successfulFiles.push({
                        id: candidateId,
                        name: file.name
                    });

                } catch (error) {

                    console.error(
                        'Failed to create candidate for file:',
                        file.name,
                        error
                    );

                    failedFiles.push(file.name);
                }
            }

            this.processedFiles = [
                ...this.processedFiles,
                ...successfulFiles
            ];

            if (successfulFiles.length > 0) {
                this.showToast(
                    'Success',
                    `${successfulFiles.length} CV(s) uploaded successfully.`,
                    'success'
                );
            }

            if (failedFiles.length > 0) {
                this.showToast(
                    'Warning',
                    `Failed to process: ${failedFiles.join(', ')}`,
                    'warning'
                );
            }

        } finally {

            this.processing = false;
        }
    }

    showToast(title, message, variant) {

        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}