page 94005 "BWK E-Tax Log Response"
{
    PageType = List;
    Caption = 'E-Tax Log Response';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "BWK E-Tax Log Response";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("BWK Etax Entry No."; Rec."BWK Etax Entry No.")
                {
                    ApplicationArea = All;
                }
                field("BWK Etax Document No."; Rec."BWK Etax Document No.")
                {
                    ApplicationArea = All;
                }
                field("BWK Status Code"; Rec."BWK Status Code")
                {
                    ApplicationArea = All;
                }
                field("BWK Etax Error Code"; Rec."BWK Etax Error Code")
                {
                    ApplicationArea = All;
                }
                // field("BWK Error Message"; Rec."BWK Error Message")
                // {
                //     ApplicationArea = All;
                // }
                field(ErrorMessage; ErrorMessage)
                {
                    Caption = 'BWK Error Message';
                    ApplicationArea = All;
                }
                field("BWK ETAX pdfURL"; Rec."BWK ETAX pdfURL")
                {
                    ApplicationArea = All;
                }
                field("BWK ETAX xmlURL"; Rec."BWK ETAX xmlURL")
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        BWKGetErrorMessage();
    end;

    var
        ErrorMessage: Text;

    procedure BWKGetErrorMessage()
    begin
        ErrorMessage := Rec.GetErrorMessage();
    end;
}