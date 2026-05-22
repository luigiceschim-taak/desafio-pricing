import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import STATUS_FIELD from '@salesforce/schema/Order.Status';
import retryIntegration from '@salesforce/apex/OrderRetryIntegrationController.retryIntegration';

const FIELDS = [STATUS_FIELD];

export default class OrderRetryIntegration extends LightningElement {
    @api recordId;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    order;

    get isIntegrationError() {
        return getFieldValue(this.order?.data, STATUS_FIELD) === 'IntegrationError';
    }

    async handleRetry() {
        this.isLoading = true;
        try {
            await retryIntegration({ orderId: this.recordId });
            this.dispatchEvent(new ShowToastEvent({
                title: 'Reintegração iniciada',
                message: 'O processo foi disparado. O status será atualizado em breve.',
                variant: 'success'
            }));
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro ao iniciar reintegração',
                message: error?.body?.message ?? 'Erro desconhecido.',
                variant: 'error',
                mode: 'sticky'
            }));
        } finally {
            this.isLoading = false;
        }
    }
}
