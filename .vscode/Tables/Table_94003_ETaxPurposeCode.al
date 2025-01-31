table 94003 "BWK ETax Purpose Code"
{
    DataClassification = ToBeClassified;
    LookupPageId = "BWK ETax Purpose Code List";

    fields
    {
        field(1; "BWK Purpose Type"; Option)
        {
            OptionMembers = CN,DN;
            OptionCaption = 'CN,DN';
            DataClassification = CustomerContent;
        }
        field(2; "BWK Purpose Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3; "BWK Purpose Name"; Text[100])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "BWK Purpose Type", "BWK Purpose Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "BWK Purpose Code", "BWK Purpose Name")
        {
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

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
}