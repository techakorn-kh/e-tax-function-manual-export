pageextension 94008 "BWK Posted General Journal" extends "Posted General Journal"
{
    layout
    {
        addlast(Control1)
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
            field("BWK Post Code"; Rec."BWK Etax Post Code")
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

        }
    }





    actions
    {
        // Add changes to page actions here
        addafter("BWK Posted Voucher")
        {
            action(UpdateGenETax)
            {
                Caption = 'Update Gen Etax';
                trigger OnAction()
                var
                    VatEntry: Record "VAT Entry";
                begin
                    VatEntry.Reset();
                    VatEntry.SetRange("Document No.", Rec."Document No.");
                    if VatEntry.FindSet() then begin
                        repeat
                            VatEntry."BWK Generate E-TAX" := false;
                            VatEntry.Modify();
                        until VatEntry.Next() = 0;
                        Message('Update complete.');
                    end;
                end;
            }
            action(UpdatePostedGen)
            {
                Caption = 'Update Posted Gen.';
                trigger OnAction()
                var
                    lrCustomer: record Customer;
                begin
                    if Rec."BWK Deposit Type Card" = Rec."BWK Deposit Type Card"::Customer then begin
                        lrCustomer.Reset();
                        lrCustomer.SetFilter("No.", '%1', Rec."BWK Deposit Of Card");
                        if lrCustomer.FindFirst() then begin
                            Rec."BWK Etax Building No." := lrCustomer."BWK Etax Building No.";
                            Rec."BWK Etax Building Name" := lrCustomer."BWK Etax Building Name";
                            Rec."BWK Etax Address1" := lrCustomer."BWK Etax Address1";
                            Rec."BWK Etax Address2" := lrCustomer."BWK Etax Address2";
                            Rec."BWK Etax Address3" := lrCustomer."BWK Etax Address3";
                            Rec."BWK Etax Street" := lrCustomer."BWK Etax Street";
                            Rec."BWK Etax City Sub" := lrCustomer."BWK Etax City Sub";
                            Rec."BWK Etax City" := lrCustomer."BWK Etax City";
                            Rec."BWK Etax Sub Country" := lrCustomer."BWK Etax Sub Country";
                            Rec."BWK Etax E-Mail" := lrCustomer."BWK Etax E-Mail";
                            Rec."BWK Etax Country ID" := lrCustomer."BWK Etax Country ID";
                            Rec."BWK Etax Address4" := lrCustomer."BWK Etax Address4";
                            Rec."BWK Etax Address5" := lrCustomer."BWK Etax Address5";
                            Rec."BWK Etax Country Name" := lrCustomer."BWK Etax Country Name";
                            Rec."BWK Etax Taxpayer Type" := lrCustomer."BWK Etax Taxpayer Type";
                            Rec."BWK Etax Taxpayer Name" := lrCustomer."BWK Etax Taxpayer Name";
                            Rec."BWK Etax Post Code" := lrCustomer."Post Code";
                            Rec."VAT Registration No." := lrCustomer."VAT Registration No.";
                            Message('Update complete.');
                        end;
                    end;
                end;
            }
        }
    }

    var
        myInt: Integer;
}