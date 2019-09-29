unit Check;

  interface

  uses
    Windows, Messages, SysUtils, Variants, Classes, Controls,
    Dialogs, StdCtrls, StrUtils,
    Xml.XMLDoc, Xml.XMLIntf,
    Generics.Collections;

  type
    TCheck = class()
      Fields: TDictionary<string,string>;
      MessageList: TStringList;

    private
      { Private declarations }
      procedure TCheck.isNumeric(item: STRING): STRING;
      procedure TCheck.isDate(item: STRING): STRING;

    public
      { Public declarations }
      Procedure TCheck.setField(line: XML): BOOLEAN;
      Procedure TCheck.compareField(item, op, variety: STRING): STRING;
      Procedure TCheck.addMessage(errno: STRING): STRING;
      Procedure TCheck.checkBasic(item, varaiety, errno: STRING): STRING;
      Procedure TCheck.checkPair(item, op1, variety, target, op2, condition, errno: STRING): STRING;

    end;

  var
    ErMessages:array[0..100] of STRING = (
     ""
    );

  implementation

  {$R *.dfm}
  //
  //
  procedure TCheck.addMessage(errno: INTEGER): STRING;
  begin
    MessageList.add(ErMessages[errno]);
  end;

  //
  //
  Procedure TCheck.setField(line: XML): BOOLEAN;
  var
    key, val: STRING;

  begin
    Fields := TDictionary<string,string>.Create;
    try
      Fields.Add(key, val);
    finally
      Fields.Free;
    end;

  //
  //
  Procedure TCheck.checkBasic(item, varaiety, errno: STRING): BOOLEAN;
  begin
    result := true;
    if compareField(item, variety) then
    begin
      result := true;
    end
    else
    begin
      addMessage(errno);
      result := false;
    end;
  end;

  //
  //
  Procedure TCheck.checkPair(item, op1, variety, target, op2, condition, errno: STRING): STRING;
  var
    x, y: STRING;
  begin

    Result := 'OK';
    if compareField(item, op1, variety) then
    begin
      if compareField(target, op2, condition) then
      begin
        addMessage(errno);
        Result := 'ng';
      end
      else
      begin
        Result := 'ok';
      end;
    end
    else
    begin
      if compareStr(y, '') = 0 then
        Result := 'thru';
    end
    end;

  end;

  //
  //
  Procedure TCheck.compareField(item, op, variety: STRING): BOOLEAN;
  var
    x, y: STRING;
    ary: TStringDynArray;
  begin
    ary := SplitString(variety, ',');
    x = Fields[item];
    result := true;
    if compareStr(op, '=') = 0 then begin
      result := false;
    end;
    for y in ary do begin
      if compareStr(y, 'NULL') = 0 then begin
        y := '';
      end;
      if compareStr(y, 'DATE') = 0 then begin
        result := isDate(x);
        exit;
      end;
      if compareStr(y, 'NUM') = 0 then begin
        result := isNumeric(x);
        exit;
      end;
      if compareStr(op, '=') = 0 then
      begin
        if compareStr(x, y) = 0 then begin
          result := 'ok';
          exit;
        end;
      end else
      begin
        if compareStr(x, y) = 0 then begin
          result := 'ng';
          exit;
        end;
      end;
    end;

  end;

  //
  //
  procedure TCheck.isNumeric(item: STRING): BOOLEAN;
  var
    x: STRING;
    n, c: INTEGER;

  begin
    result := true;
    val(Fields[item], n, c);
    if c <> 0 then begin
      Result := false;
    end;

  end;

  //
  //
  procedure TCheck.isDate(item: STRING): BOOLEAN;
  var
    x, yx, mx, dx, hms: STRING;
    yyyy, mm, dd, hh, ii, ss: INTEGER;
    d: Time;

  begin
    result := true;
    x := Fields[item];
    yx := copy(x, 0, 4);
    mx := copy(x, 5, 2);
    dx := copy(x, 8, 2);
    hms := copy(x, 11, 8);
    try
      d := strToTime(yx+'/'+mx+'/'+dx+' '+hms);
      if year(d) <> GV-year then
        addMessage(errno);
        Result := false;
    except on e: Exception do
      addMessage(errno);
      Result := false;
    end;

  end;

  //
  //
  procedure TCheck.loadXML(child_nodes: IXMLNodeList);
  var
    xdoc: IXMLDocument;
    child_node: IXMLNode;
    i: Integer;
    key, val: STRING;
  begin

    for i := 0 to child_nodes.Count - 1 do
    begin
      child_node := child_nodes[i];
      key := xdoc.DocumentElement.ChildValues['field'];
      val := xdoc.DocumentElement.ChildValues['value'];
      Fields[key] := val;
    end;

  end;

end.