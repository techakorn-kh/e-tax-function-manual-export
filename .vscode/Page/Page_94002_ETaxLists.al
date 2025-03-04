page 94002 "BWK E-Tax Lists"
{

    PageType = List;
    SourceTable = "BWK E-Tax Header";
    Caption = 'E-Tax Lists';
    CardPageId = "BWK E-Tax Card";
    UsageCategory = Lists;
    ApplicationArea = all;
    SourceTableView = sorting("BWK E-Tax Document Type", "BWK End date of Month");
    DataCaptionExpression = StrSubstNo('[%1] E-Tax', Rec."BWK E-Tax Document Type");
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            repeater("BWK General")
            {
                Caption = 'General';
                field("BWK E-Tax Document Type"; Rec."BWK E-Tax Document Type")
                {
                    ApplicationArea = all;
                }
                field("BWK End date of Month"; Rec."BWK End date of Month")
                {
                    ApplicationArea = All;
                }
                field("BWK Year-Month"; Rec."BWK Year-Month")
                {
                    ApplicationArea = All;
                }
                field("BWK Month Name"; Rec."BWK Month Name")
                {
                    ApplicationArea = All;
                }

                field("BWK Year No."; Rec."BWK Year No.")
                {
                    ApplicationArea = All;
                }
                field("BWK Status Lock"; Rec."BWK Status Lock")
                {
                    ApplicationArea = All;
                }
                field("BWK Total Amount"; Rec."BWK Total Amount")
                {
                    ApplicationArea = All;
                }
                field("BWK Total VAT Amount"; Rec."BWK Total VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("BWK Total Amount Incl. VAT"; Rec."BWK Total Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("BWK Function")
            {
                Caption = '&Function';
                action("BWK Create Next Month")
                {
                    Caption = 'Create Next Month';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = NextRecord;
                    trigger OnAction()
                    var
                        LRecETaxHeader: Record "BWK E-Tax Header";
                        LRecETaxHeaderFind: Record "BWK E-Tax Header";
                        LDateEndDateOfMonth, LDateEndDateOfMonth2 : Date;
                        LPageETaxCard: Page "BWK E-Tax Card";
                    begin
                        if Rec."BWK E-Tax Document Type" = Rec."BWK E-Tax Document Type"::" " then begin
                            Error('Document Type must not be blank value.');
                        end;

                        if Confirm('Do you confirm create E-Tax next month?', false) then begin
                            LRecETaxHeader.Reset();
                            LRecETaxHeader.SetFilter("BWK E-Tax Document Type", '%1', Rec."BWK E-Tax Document Type");

                            If not LRecETaxHeader.FindLast() then begin
                                LDateEndDateOfMonth := CalcDate('CM', Today);
                            end else begin
                                LDateEndDateOfMonth := CalcDate('CM+1M', LRecETaxHeader."BWK End date of Month");
                            end;

                            LDateEndDateOfMonth2 := CalcDate('<CM>', LDateEndDateOfMonth);

                            LRecETaxHeader.Init();
                            LRecETaxHeader."BWK E-Tax Document Type" := Rec."BWK E-Tax Document Type";
                            LRecETaxHeader.Validate("BWK End date of Month", LDateEndDateOfMonth2);
                            LRecETaxHeader.Insert(true);
                        end;
                    end;
                }
            }
        }
    }
}