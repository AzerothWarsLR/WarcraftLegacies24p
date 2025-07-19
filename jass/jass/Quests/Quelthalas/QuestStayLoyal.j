library QuestStayLoyal requires Persons, GeneralHelpers

  globals 
    private constant integer QUEST_RESEARCH_ID = 'R08Z'   //This research is given when the quest is completed
  endglobals

  struct QuestStayLoyal extends QuestData
    private method operator Global takes nothing returns boolean
      return true
    endmethod

    private method operator CompletionPopup takes nothing returns string
      return "The Blood Elves stay loyal to Illidan"
    endmethod

    private method operator CompletionDescription takes nothing returns string
      return "Stay allied to Illidan"
    endmethod    

    private method OnComplete takes nothing returns nothing
      set GREAT_TREACHERY.Progress = QUEST_PROGRESS_FAILED
      set SUMMON_KIL.Progress = QUEST_PROGRESS_FAILED
      call UnitRemoveAbilityBJ( 'A0IK', LEGEND_KAEL.Unit)
      call UnitRemoveAbilityBJ( 'A0IF', LEGEND_KAEL.Unit)
    endmethod

    public static method create takes nothing returns thistype
      local thistype this = thistype.allocate("Refuse Kil'Jaeden's Offer", "Kil'jaeden has approached Kael with an offer of power and salvation. He should refuse it and resist the temptation of Fel power.", "ReplaceableTextures\\CommandButtons\\BTNDemonHunter2.blp")
      call this.AddQuestItem(QuestItemCastSpell.create('A0IK', true))
      set this.ResearchId = QUEST_RESEARCH_ID
      return this
    endmethod
  endstruct

endlibrary