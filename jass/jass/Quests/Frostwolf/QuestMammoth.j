//If the Centaur Khan dies, OR a time elapses, give Thunder Bluff to a Horde player. 
library QuestMammoth requires QuestData, LegendFrostwolf, FrostwolfSetup, GeneralHelpers 

  globals 
    private constant integer QUEST_RESEARCH_ID = 'R096' 
  endglobals 

  struct QuestMammoth extends QuestData 

    private method operator CompletionPopup takes nothing returns string 
      return "Rexxar ventures north into lands once thought incompatible with life, and discovers the paradise of furred megafauna that is the Borean Tundra. He tames the woolly mammoths there, and teaches the Frostwolf to ride them into battle." 
    endmethod 

    private method operator CompletionDescription takes nothing returns string 
      return "Learn to train Mammoth Wranglers from the Beast Pen" 
    endmethod 

    private method OnComplete takes nothing returns nothing 
    endmethod 

    public static method create takes nothing returns thistype 
      local thistype this = thistype.allocate("Lone Wanderer", "Rexxar's wanderlust has brought him into contact with all kinds of beasts. Yet there is one major landmass he has never ventured to: the cold expanse of Northrend. Surely the wild things roam free even there.", "ReplaceableTextures\\CommandButtons\\BTNVrykulWarMammoth.blp") 
      call this.AddQuestItem(QuestItemLegendInRect.create(LEGEND_REXXAR, gg_rct_Borean_Tundra, "Borean Tundra"))
      set this.ResearchId = QUEST_RESEARCH_ID 
      return this 
    endmethod 
  endstruct 

endlibrary