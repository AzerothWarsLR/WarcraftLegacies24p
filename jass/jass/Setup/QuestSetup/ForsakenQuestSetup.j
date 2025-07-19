library ForsakenQuestSetup requires ForsakenSetup

  public function OnInit takes nothing returns nothing

    set FACTION_FORSAKEN.StartingQuest = FACTION_FORSAKEN.AddQuest(QuestScholomanceBuild.create())
    call FACTION_FORSAKEN.AddQuest(QuestReanimateSylvanas.create())
    set QUEST_UNDERCITY = QuestUndercity.create()
    call FACTION_FORSAKEN.AddQuest(QUEST_UNDERCITY)

    call FACTION_FORSAKEN.AddQuest(QuestThePlaguelands.create())
    call FACTION_FORSAKEN.AddQuest(QuestRetakeSunwell.create())
    call FACTION_FORSAKEN.AddQuest(QuestTheNine.create())
    call FACTION_FORSAKEN.AddQuest(QuestTakeRevenge.create())

  endfunction

endlibrary