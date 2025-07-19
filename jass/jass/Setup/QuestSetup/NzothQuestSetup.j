library NzothQuestSetup requires NzothSetup

  public function OnInit takes nothing returns nothing

    set FACTION_NZOTH.StartingQuest = FACTION_NZOTH.AddQuest(QuestSecureStart.create())
    call FACTION_NZOTH.AddQuest(QuestNazjatar.create()) 
    call FACTION_NZOTH.AddQuest(QuestIslandRaid.create())
    call FACTION_NZOTH.AddQuest(QuestWestRaid.create())
    call FACTION_NZOTH.AddQuest(QuestEastRaid.create())
    call FACTION_NZOTH.AddQuest(QuestDefeatIllidan.create())
    call FACTION_NZOTH.AddQuest(QuestBloodCurse.create())



  endfunction

endlibrary