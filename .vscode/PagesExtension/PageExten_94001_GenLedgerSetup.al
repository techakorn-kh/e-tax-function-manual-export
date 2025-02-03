pageextension 94001 "BWK General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(content)
        {
            group("E-TAX")
            {
                group(PathSetup)
                {
                    Caption = 'Path Setup';

                    field("BWK Etax Path Text File"; Rec."BWK Etax Path Text File")
                    {
                        ApplicationArea = All;

                    }
                    field("BWK Etax Path PDF File"; Rec."BWK Etax Path PDF File")
                    {
                        ApplicationArea = All;

                    }
                }
                group(NoSeriesSetup)
                {
                    Caption = 'No. Series Setup';
                    field("BWK DN No. Series"; Rec."BWK DN No. Series")
                    {
                        ApplicationArea = All;
                    }
                }
                group(FormID)
                {
                    Caption = 'Form ID Setup';

                    field("BWK Etax Sales Invoice Form ID"; Rec."BWK Etax Sales Invoice Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales DN Form ID"; Rec."BWK Etax Sales DN Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales Cr Memo Form ID"; Rec."BWK Etax Sales Cr Memo Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales Receipt Form ID"; Rec."BWK Etax Sales Receipt Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Rec Deposit Form ID"; Rec."BWK Etax Rec Deposit Form ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Etax Rec Tax KeyIn Form ID"; Rec."BWK Etax Rec Tax KeyIn Form ID")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    var
        myInt: Integer;
}