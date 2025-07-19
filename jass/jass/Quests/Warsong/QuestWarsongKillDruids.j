library QuestWarsongKillDruids requires WarsongSetup, LegendDruids, Display

  globals
    private constant integer QUEST_RESEARCH_ID = 'R08M'   //This research is given when the quest is completed
  endglobals

  struct QuestWarsongKillDruids extends QuestData
    private static integer EXPERIENCE_REWARD = 10000

    private method operator CompletionPopup takes nothing returns string
      return "Nordrassil has been captured. The Warsong is supreme!"
    endmethod

    private method operator CompletionDescription takes nothing returns string
      return "Grom Hellscream gains " + I2S(EXPERIENCE_REWARD) + " experience and you can now train Foreman Glibbs"
    endmethod

    private method OnComplete takes nothing returns nothing
      call AddHeroXP(LEGEND_GROM.Unit, EXPERIENCE_REWARD, true)
    endmethod

    public static method create takes nothing returns thistype
      local thistype this = thistype.allocate("Tear It Down", "The World Tree, Nordrassil, is the Night Elves' source of immortality. Capture it to cripple them permanently.","ReplaceableTextures\\CommandButtons\\BTNFountainOfLife.blp")
      call this.AddQuestItem(QuestItemControlLegend.create(LEGEND_NORDRASSIL, false))
      call this.AddQuestItem(QuestItemLegendNotPermanentlyDead.create(LEGEND_GROM))
      set this.ResearchId = QUEST_RESEARCH_ID
      return this
    endmethod
  endstruct

endlibrary