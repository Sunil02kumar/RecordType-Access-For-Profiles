@isTest
private class RecordTypeFinderForProfileControllerTest {
	
	private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.update_element)
                response.put('response_x', new MetadataService.updateResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkStatus_element)
                response.put('response_x', new MetadataService.checkStatusResponse_element());
            else if(request instanceof MetadataService.create_element)
                response.put('response_x', new MetadataService.createResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.delete_element)
                response.put('response_x', new MetadataService.deleteResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            return; 
        }
    } 


	@isTest static void test_method_one() {
		// Null Web Service mock implementation
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		RecordTypeFinderForProfileController ss =new RecordTypeFinderForProfileController();
		Profile f=[select id,name from profile Limit 1];
		ss.selectedProfile=f.name;
		ss.selectedObject='Account';
		ss.retrieveMetadataItem();
		//ss.checkAsyncRequest();
		ss.receiveMetadataZipFile();
		ss.receiveComplete();
	}
}