tableextension 94002 "BWK Genaral Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(94001; "BWK Etax Export Text File"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export Text File to Path';
            Description = 'Etax';
        }
        field(94002; "BWK Etax Export PDF File"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export PDF File to Path';
            Description = 'Etax';
        }
        field(94003; "BWK Etax Path PDF Sign"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Path PDF Sign';
            Description = 'Etax';
        }
        field(94004; "BWK Etax Sales Invoice Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Sales Invoice Form ID';
        }
        field(94005; "BWK Etax Sales Cr Memo Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Sales Credit Memo Form ID';
        }
        field(94006; "BWK Etax Sales DN Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Sales Debit Note Form ID';
        }
        field(94007; "BWK Etax Sales Receipt Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Path Sales Receipt Form ID';
        }
        field(94008; "BWK ETAX xml Path"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK ETAX xml Path';
        }
        field(94009; "BWK Sales Invoice Form ID GP"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Sales Invoice Form ID Group';
        }
        field(94010; "BWK Web Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(94011; "BWK I-Net Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(94012; "BWK Seller Tax ID"; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(94013; "BWK Seller Brance ID"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(94014; "BWK API Key"; Text[500])
        {
            DataClassification = CustomerContent;
        }
        field(94015; "BWK User Code"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(94016; "BWK Access Key"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(94017; "BWK Service Code"; Text[10])
        {
            DataClassification = CustomerContent;
        }
        field(94018; "BWK Authorization"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(94019; "BWK DN No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(94020; "BWK Etax Rec Deposit Form ID"; Integer)
        {
            Caption = 'BWK Etax Receipt Deposit Form ID';
            DataClassification = CustomerContent;
        }
        field(94021; "BWK Etax Rec Tax KeyIn Form ID"; Integer)
        {
            Caption = 'BWK Etax Receipt Tax KeyIn Form ID';
            DataClassification = CustomerContent;
        }
    }

    var
        myInt: Integer;
}