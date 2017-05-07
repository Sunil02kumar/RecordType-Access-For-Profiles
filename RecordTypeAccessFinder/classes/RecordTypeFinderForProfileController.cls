public class RecordTypeFinderForProfileController 
{
    public String MetadataFileName {get; set;}
    public String MetadataFileData {get; set;}
    public MetadataService.AsyncResult AsyncResult {get; private set;}
    public String MetaDataRetrieveZip { get; private set; } 
    //public List<MetadataFile> MetadataFiles { get; set; }  
    
    
    //Variable to store report id
    public string ReportId{get;set;}
    //Variable to display report link
    public boolean DisplayReportLink{get;set;}
    
    public String selectedProfile{get;set;} 
    public String selectedObject{get;set;}
    
    public  RecordTypeFinderForProfileController(){ 
        List<Report> temp=[Select Name, DeveloperName, id From Report where Developername='Record_Type_Access_Grouped_By_profiles' Limit 1];
        if(temp.size()>0){
            ReportId=temp[0].Id;
        }
        
        listofprofiles=listMetadataItems('Profile');
        listofObjects=listMetadataItems('CustomObject');
     }  
    
    private list<selectoption> listofprofiles=new List<selectoption>();
    private list<selectoption> listofObjects=new List<selectoption>();
    
    public List<selectoption> getProfileList(){
        list<selectoption> temp=new list<selectoption>();
        temp.add(new selectoption('*','All'));
        if(listofprofiles.size()>0){
            temp.addall(listofprofiles);    
        }
        
        system.debug('**********temp'+temp);
        return temp;
    }
    public List<selectoption> getObjectList(){
        list<selectoption> temp=new list<selectoption>();
        if(listofObjects.size()>0){
            temp.addall(listofObjects); 
        }
        system.debug('**********temp'+temp);
        return temp;
    }
    
    
    //below method will return list of option for metadata. metadata type like profile, apex class etc will be passed as arguement to this method
    public List<selectoption> listMetadataItems(String str)
    {
        // List Metadata items for the selected Metadata Type
        List<SelectOption> MetaDataItems = new List<SelectOption>();       
        MetadataService.MetadataPort service = createService();             
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        //queryLayout.folder = MetaDataFolder;
        queryLayout.folder = '';
        queryLayout.type_x = str;
        queries.add(queryLayout); 
        MetadataService.FileProperties[] fileProperties;
        if(!Test.isRunningTest()) {
            fileProperties = service.listMetadata(queries, 29);
        }     
        
        
        // Sort
        List<String> fullNames = new List<String>();
        if(fileProperties!=null)
        {
            for(MetadataService.FileProperties fileProperty : fileProperties)
                fullNames.add(fileProperty.fullName);
            fullNames.sort();
            for(String fullName : fullNames)
                MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
        }

        return MetaDataItems;    
    }
    
    public PageReference retrieveMetadataItem(){
          
         
        DisplayReportLink=false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
        
        // Reset state from any previous requests
        MetaDataRetrieveZip = null;
        // Construct unmanaged package with list of desired components to retrieve in zip
        MetadataService.MetadataPort service = createService();             
        MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
        retrieveRequest.apiVersion = 29;
        retrieveRequest.singlePackage = false;
        retrieveRequest.unpackaged = new MetadataService.Package_x();
        retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
        //specify object
        MetadataService.PackageTypeMembers packageType1 = new MetadataService.PackageTypeMembers();
        packageType1.name ='CustomObject';
        packageType1.members = new String[] {selectedObject};        
        retrieveRequest.unpackaged.types.add(packageType1);
        //specify profile
        MetadataService.PackageTypeMembers packageType2 = new MetadataService.PackageTypeMembers();
        packageType2.name = 'Profile'; 
        packageType2.members = new String[] {selectedProfile};
        retrieveRequest.unpackaged.types.add(packageType2);
        
        
        AsyncResult = service.retrieve(retrieveRequest);
                        
        return null;    
    }
    
    public PageReference checkAsyncRequest()
    {
        // Check the status of the retrieve request
        MetadataService.MetadataPort service = createService();
        MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
        if(aysncResults[0].done)
        {
            // Errors?
            if(aysncResults[0].state == 'Error')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, aysncResults[0].message));
                AsyncResult = null;             
            }
            else
            {
                // Place Base64 encoded zip data onto the page for the JSZip library to handle
                MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(AsyncResult.id);
                MetaDataRetrieveZip = retrieveResult.zipFile;
                //MetadataFiles = new List<MetadataFile>();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
                AsyncResult = null;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
        }   

        return null;
    }
    public String operationType{get;set;}
    
    public PageReference receiveMetadataZipFile()
    {
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Reading ' + MetaDataFileName + '...'));
        MetadataFile metaDataFile = new MetadataFile();
        metaDataFile.fullName = MetaDataFileName;
        metaDataFile.content = MetaDataFileData;
        //Create record in custom object by reading file content    
        CreateRecordsinCustomObject(metaDataFile);
        return null;
    }
    
    public PageReference receiveComplete()
    {
        // Completed, cleared Base64 encoded zip data from viewstate
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Metadata retrieve completed'));
        MetaDataRetrieveZip = null;  
        if(recordsToInsertlist.size()>0){
            Schema.SObjectField ftoken = RecordTypeAccess__c.Fields.uniqueKey__c;
            Database.UpsertResult[] srList = Database.upsert(recordsToInsertlist,ftoken,false);
            for (Database.UpsertResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
                        System.debug('fields that affected this error: ' + err.getFields());
                        
                    }
                }
            }
            DisplayReportLink=true;
            system.debug('******all records got inserted:'+recordsToInsertlist.size());
        }
        
        return null;
    }
    
    private static MetadataService.MetadataPort createService()
    { 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }   
    
    // Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
    public class MetadataFile extends MetadataService.MetadataWithContent
    {
        public String getFullname()
        {
            return fullName;
        }
        
        public String getContent()
        {
            return content;
        }
    }
    
    
    public List<RecordTypeAccess__c> recordsToInsertlist=new List<RecordTypeAccess__c>();
    
    public void CreateRecordsinCustomObject(Metadatafile doc){
        
        if(doc.fullname!=null){
            if(doc.fullname.endswith('.profile')){
                String textToParse=blob.valueof(doc.content).tostring();
                String profileName=doc.fullname.split('/')[doc.fullname.split('/').size()-1];
                 
                 DOM.Document docu = new DOM.Document();
                try {
                
                    docu.load(textToParse);    
                    DOM.XMLNode root = docu.getRootElement();
                    List<RecordTypeAccess__c> temp=Utility_XmlParser.walkThroughProfileXml(root,profileName);
                    if(temp.size()>0){
                        recordsToInsertlist.addall(temp);
                    }
                   
                    system.debug('****recordsToInsertlist.size() in CreateRecordsinCustomObject method='+recordsToInsertlist.size());
                } catch (System.XMLException e) {  
                  // invalid XML
                  system.debug('*****exception in execute method='+e.getMessage());
                }
            }    
        }
        
    
    }
    
}