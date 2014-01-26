--string aggregate function
--aggregates strings together. Works like sum or avg.


create or replace type stragg_type as object
(
  string varchar2(32767),

  static function ODCIAggregateInitialize
    ( sctx in out stragg_type )
    return number ,

  member function ODCIAggregateIterate
    ( self  in out stragg_type ,
      value in     varchar2
    ) return number ,

  member function ODCIAggregateTerminate
    ( self        in  stragg_type,
      returnvalue out varchar2,
      flags in number
    ) return number ,

  member function ODCIAggregateMerge
    ( self in out stragg_type,
      ctx2 in     stragg_type
    ) return number
);
/

create or replace type body stragg_type
is

  static function ODCIAggregateInitialize
  ( sctx in out stragg_type )
  return number
  is
  begin

    sctx := stragg_type( null ) ;

    return ODCIConst.Success ;

  end;

  member function ODCIAggregateIterate
  ( self  in out stragg_type ,
    value in     varchar2
  ) return number
  is
  begin

    self.string := substr(self.string || ',' || value,1,1500) ;

    return ODCIConst.Success;

  end;

  member function ODCIAggregateTerminate
  ( self        in  stragg_type ,
    returnvalue out varchar2 ,
    flags       in  number
  ) return number
  is
  begin

    returnValue := substr(ltrim( self.string, ',' ),1,1500);

    return ODCIConst.Success;

  end;

  member function ODCIAggregateMerge
  ( self in out stragg_type ,
    ctx2 in     stragg_type
  ) return number
  is
  begin

    self.string := substr(self.string || ctx2.string,1,1500);

    return ODCIConst.Success;

  end;

end;
/

create or replace function stragg
  ( input varchar2 )
  return varchar2
  deterministic
  parallel_enable
  aggregate using stragg_type
;
/
