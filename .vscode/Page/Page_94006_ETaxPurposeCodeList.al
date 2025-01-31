page 94006 "BWK ETax Purpose Code List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BWK ETax Purpose Code";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("BWK Purpose Type"; Rec."BWK Purpose Type")
                {
                    ApplicationArea = All;
                }
                field("BWK Purpose Code"; Rec."BWK Purpose Code")
                {
                    ApplicationArea = All;
                }
                field("BWK Purpose Name"; Rec."BWK Purpose Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    // actions
    // {
    //     area(Processing)
    //     {
    //         action(ActionName)
    //         {
    //             ApplicationArea = All;

    //             trigger OnAction()
    //             begin

    //             end;
    //         }
    //     }
    // }

    var
        myInt: Integer;
}