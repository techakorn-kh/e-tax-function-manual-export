page 94001 "BWK E-Tax Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Finance Cue";

    layout
    {
        area(content)
        {
            cuegroup(Master)
            {
                Caption = 'Master';

                // field("BWK Vendor"; Rec."BWK Vendor")
                // {
                //     ApplicationArea = Suite;
                //     DrillDownPageID = "Vendor List";
                // }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }


    trigger OnOpenPage()
    var
        lintDay: Integer;
        lintMonth: Integer;
        lintYear: Integer;
        ldateEndOfMonth: Date;
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";


}