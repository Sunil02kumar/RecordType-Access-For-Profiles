/*
Created by: Sunil Kumar
Created date:16th May,2014
Test Class: Test_Utility_Xmlparser
*/
public  class Utility_XmlParser {
    
    
    // Recursively walk through the XML
    public static List<RecordTypeAccess__c> walkThroughProfileXml(DOM.XMLNode node, String Profilename) {
        List<RecordTypeAccess__c> recrdtypelist=new List<RecordTypeAccess__c>();
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            system.debug('**********node.getName() -'+node.getName());
            if(node.getName().equalsIgnoreCase('Profile')){
                
                for (Dom.XMLNode child1: node.getChildElements()) {
                    if(child1.getName().equalsIgnoreCase('recordTypeVisibilities')){
                        RecordTypeAccess__c rtacc=new RecordTypeAccess__c();
                        for (Dom.XMLNode child2: child1.getChildElements()) {
                            system.debug('**********child2.getName() -'+child2.getName());
                            if(child2.getName().equalsIgnoreCase('recordType')){
                    
                                String str=child2.gettext().trim();
                                system.debug('******str-'+str);
                                String[] temp=str.split('\\.');
                                if(temp[0]!=null && temp[0]!=''){
                                    rtacc.Object_Name__c=temp[0].trim();    
                                }
                                if(temp[1]!=null && temp[1]!=''){
                                    rtacc.RecordType_Name__c=temp[1].trim();    
                                }                               
                                rtacc.Profile_Name__c=Profilename;
                            }
                            else if(child2.getName().equalsIgnoreCase('visible')){
                                String str=child2.gettext().trim();
                                if(str.equalsignorecase('True')){
                                    rtacc.Visibility__c=true;   
                                }else{
                                    rtacc.Visibility__c=false;
                                }
                            }
                            
                        }
                        if(rtacc.RecordType_Name__c!=null && rtacc.RecordType_Name__c!='' ){
                            
                                rtacc.uniqueKey__c=rtacc.object_Name__c + rtacc.RecordType_Name__c + rtacc.Profile_Name__c;
                                recrdtypelist.add(rtacc);   
                        }
                        
                        system.debug('******rtacc:'+rtacc); 
                    }
                }
            }
        }
        
        system.debug('****recrdtypelist in walkThroughProfileXml='+recrdtypelist.size());
        return recrdtypelist; 
    }

}