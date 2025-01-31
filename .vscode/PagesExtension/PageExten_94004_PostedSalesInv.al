pageextension 94004 "BWK Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(content)
        {
            group("E-TAX")
            {
                field("BWK Building No"; Rec."BWK Etax Building No.")
                {
                    ApplicationArea = All;

                }
                field("BWK Building Name"; Rec."BWK Etax Building Name")
                {
                    ApplicationArea = All;
                }
                field("BWK Address1"; Rec."BWK Etax Address1")
                {
                    ApplicationArea = All;
                }
                field("BWK Address2"; Rec."BWK Etax Address2")
                {
                    ApplicationArea = All;
                }
                field("BWK Address3"; Rec."BWK Etax Address3")
                {
                    ApplicationArea = All;
                }
                field("BWK Street"; Rec."BWK Etax Street")
                {
                    ApplicationArea = All;
                }
                field("BWK City Sub"; Rec."BWK Etax City Sub")
                {
                    ApplicationArea = All;
                }
                field("BWK City"; Rec."BWK Etax City")
                {
                    ApplicationArea = All;
                }
                field("BWK Sub Country"; Rec."BWK Etax Sub Country")
                {
                    ApplicationArea = All;
                }
                field("BWK Pose Code"; Rec."Sell-to Post Code")
                {
                    ApplicationArea = All;
                    caption = 'รหัสไปรษณีย์';
                }
                field("BWK E-Mail"; Rec."BWK Etax E-Mail")
                {
                    ApplicationArea = All;
                }
                field("BWK Country ID"; Rec."BWK Etax Country ID")
                {
                    ApplicationArea = All;
                }
                field("BWK Country Name"; Rec."BWK Etax Country Name")
                {
                    ApplicationArea = All;
                }
                field("BWK Taxpayer Type"; Rec."BWK Etax Taxpayer Type")
                {
                    ApplicationArea = All;
                }
                field("BWK Taxpayer Name"; Rec."BWK Etax Taxpayer Name")
                {
                    ApplicationArea = All;
                }
                field("BWK VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("BWK Etax Branch Code"; Rec."BWK Etax Branch Code")
                {
                    ApplicationArea = All;
                }
                field("BWK Is Debit Note"; Rec."BWK Is Debit Note")
                {
                    ApplicationArea = All;
                }
                field("BWK Applies-to ID"; Rec."BWK Applies-to ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }





    actions
    {
        // Add changes to page actions here
        // addlast(processing)
        // {
        //     action(UpdateApplyID)
        //     {
        //         Caption = 'Update Applied to ID';
        //         trigger OnAction()
        //         begin
        //             Rec."BWK Applies-to ID" := 'IV2401-0001';
        //             Rec.Modify();
        //             CurrPage.Update();
        //         end;
        //     }
        // }
    }

    var
        myInt: Integer;
}