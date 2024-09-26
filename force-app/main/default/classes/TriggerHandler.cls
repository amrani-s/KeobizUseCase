public interface TriggerHandler {
  
    
    void BeforeInsert(List<SObject> newRecord); 
    void beforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap);
    void BeforeDelete(Map<Id, SObject> oldRecord); 
    void AfterInsert(Map<Id, SObject> newRecord); 
    void AfterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap); 
    void AfterDelete(Map<Id, SObject> oldRecord); 
    void AfterUndelete(Map<Id, SObject> oldRecord); 
    
}