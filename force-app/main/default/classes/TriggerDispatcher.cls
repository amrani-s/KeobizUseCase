public class TriggerDispatcher {
    public static void Run(TriggerHandler handler) {
         
        
        if (Trigger.IsBefore ){
            
            if (Trigger.IsInsert)
            handler.BeforeInsert(trigger.new);
            if (Trigger.IsUpdate)
            handler.BeforeUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap); 
            if (Trigger.IsDelete)
            handler.BeforeDelete(trigger.oldMap);
        }         
     
        if (Trigger.IsAfter) {
            
            if (Trigger.IsInsert)
            handler.AfterInsert(Trigger.newMap);
            if (Trigger.IsUpdate){
                
                handler.AfterUpdate(trigger.old, trigger.new, trigger.oldMap, trigger.newMap);
            }
            if (trigger.IsDelete)
            handler.AfterDelete(trigger.oldMap);
            if (trigger.isUndelete)
            handler.AfterUndelete(trigger.oldMap);
        }
    }
}