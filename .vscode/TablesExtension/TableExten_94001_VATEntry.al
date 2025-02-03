tableextension 94001 "BWK  Etax VAT Entry" extends "VAT Entry"
{
    fields
    {
        field(94000; "BWK Export File E-TAX"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Export File E-TAX';
        }

        field(94001; "BWK Document Type"; Enum "BWK E-Tax Document Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Type';
        }

        field(94002; "BWK End date of Month"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'End date of Month';
        }
    }

    var
        myInt: Integer;
}