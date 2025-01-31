table 94002 "BWK E-Tax Log Response"
{
    Caption = 'BWK E-Tax Log Response';

    fields
    {
        field(1; "BWK Etax Text"; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'BWK Etax Text';
        }
        field(2; "BWK Etax Error Code"; Text[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BWK Etax Error Code';
        }
        field(3; "BWK Etax Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'BWK Etax Document No.';
        }
        field(4; "BWK Etax Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            Caption = 'BWK Etax Entry No.';
        }
        field(5; "BWK Transaction Code"; Text[100])
        {
            DataClassification = SystemMetadata;
        }
        field(6; "BWK Error Message"; Text[1024])
        {
            DataClassification = SystemMetadata;
        }
        field(7; "BWK Status Code"; text[20])
        {
            DataClassification = SystemMetadata;
        }
        field(8; "BWK ETAX pdfURL"; Text[1024])
        {
            DataClassification = SystemMetadata;
        }
        field(9; "BWK ETAX xmlURL"; Text[1024])
        {
            DataClassification = SystemMetadata;
        }
        field(10; "BWK Etax Document Type"; Enum "BWK E-Tax Document Type")
        {
            DataClassification = SystemMetadata;
        }
        field(11; "BWK Etax End date of Month"; Date)
        {
            DataClassification = SystemMetadata;
        }
        field(12; "BWK Create DateTime"; DateTime)
        {
            DataClassification = SystemMetadata;
        }
        field(13; "BWK Create by User"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(14; "BWK Error Message Blob"; BLOB)
        {
            DataClassification = SystemMetadata;
            Caption = 'BWK Error Message Blob';
        }
    }

    keys
    {
        key(Key1; "BWK Etax Document No.", "BWK Etax Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin
        "BWK Etax Entry No." := GetLastEntry();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure GetLastEntry(): Integer
    var
        LogResponse: Record "BWK E-Tax Log Response";
    begin
        LogResponse.Reset();
        LogResponse.SetCurrentKey("BWK Etax Document No.", "BWK Etax Entry No.");
        LogResponse.SetRange("BWK Etax Document No.", Rec."BWK Etax Document No.");
        if LogResponse.FindLast() then
            exit(LogResponse."BWK Etax Entry No." + 1);
        exit(1);
    end;

    procedure SetErrorMessage(NewErrorMessage: Text)
    var
        OutStream: OutStream;
    begin
        Clear("BWK Error Message Blob");
        "BWK Error Message Blob".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewErrorMessage);
        Modify();
    end;

    procedure GetErrorMessage() BWKErrorMessage: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("BWK Error Message Blob");
        "BWK Error Message Blob".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("BWK Error Message Blob")));
    end;
}