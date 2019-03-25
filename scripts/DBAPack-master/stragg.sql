/*
DROP FUNCTION stragg;
DROP TYPE string_agg_type;
*/

create or replace type string_agg_type as object
  (
     total varchar2(4000),
     static function
          ODCIAggregateInitialize(sctx IN OUT string_agg_type )
          return number,
     member function
          ODCIAggregateIterate(self IN OUT string_agg_type ,
                               value IN varchar2 )
          return number,
      member function
       ODCIAggregateTerminate(self IN string_agg_type,
                                 returnValue OUT  varchar2,
                                 flags IN number)
          return number,
      member function
          ODCIAggregateMerge(self IN OUT string_agg_type,
                             ctx2 IN string_agg_type)
          return number
  );
/

create or replace type body string_agg_type
    is
    
    static function ODCIAggregateInitialize(sctx IN OUT string_agg_type)
    return number
    is
    begin
        sctx := string_agg_type( null );
        return ODCIConst.Success;
   end;
   
   member function ODCIAggregateIterate(self IN OUT string_agg_type,
                                     value IN varchar2 )
   return number
   is
   begin
       if  self.total is null then
         self.total := self.total || value;
       else
         self.total := self.total || ',' || value;
       end if;
       return ODCIConst.Success;
   end;

   member function ODCIAggregateTerminate(self IN string_agg_type,
                                      returnValue OUT varchar2,
                                       flags IN number)
   return number
   is
   begin
       returnValue := self.total;
       return ODCIConst.Success;
   end;
   
   member function ODCIAggregateMerge(self IN OUT string_agg_type,
                                      ctx2 IN string_agg_type)
   return number
   is
   begin
       self.total := self.total || ctx2.total;
       return ODCIConst.Success;
   end;
   
   
   end;
 /

CREATE or replace
FUNCTION stragg(input varchar2 )
RETURN varchar2
PARALLEL_ENABLE AGGREGATE USING string_agg_type;
/