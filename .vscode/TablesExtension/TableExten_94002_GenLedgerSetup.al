tableextension 94002 "BWK Genaral Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(94001; "BWK Etax Path Text File"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export Text File to Path';
            Description = 'Etax';
        }

        field(94002; "BWK Etax Path PDF File"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export PDF File to Path';
            Description = 'Etax';
        }

        field(94014; "BWK DN No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(94015; "BWK Etax Sales Invoice Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Invoice Form ID';
        }

        field(94016; "BWK Etax Sales Cr Memo Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Credit Memo Form ID';
        }

        field(94017; "BWK Etax Sales DN Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Debit Note Form ID';
        }

        field(94018; "BWK Etax Sales Receipt Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Receipt Form ID';
        }
        field(94019; "BWK Etax Rec Deposit Form ID"; Integer)
        {
            Caption = 'BWK Etax Receipt Deposit Form ID';
            DataClassification = CustomerContent;
        }
        field(94020; "BWK Etax Rec Tax KeyIn Form ID"; Integer)
        {
            Caption = 'BWK Etax Receipt Tax KeyIn Form ID';
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}