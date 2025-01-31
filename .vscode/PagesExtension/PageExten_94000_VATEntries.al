pageextension 94000 "BWK VAT Entries" extends "VAT Entries"
{
    layout
    {
        //Customize Siravich 031023 ASB2310-0034
        addlast(Control1)
        {
            field("BWK Generate E-TAX"; Rec."BWK Generate E-TAX")
            {
                ApplicationArea = All;

            }
            field("BWK Document Type"; Rec."BWK Document Type")
            {
                ApplicationArea = All;

            }
            field("BWK End date of Month"; Rec."BWK End date of Month")
            {
                ApplicationArea = All;

            }
        }
        //Customize Siravich 031023 ASB2310-0034
    }

    actions
    {

    }

    var
        myInt: Integer;
}