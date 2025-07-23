//If the Centaur Khan dies, OR a time elapses, give Thunder Bluff to a Horde player. 
library QuestRagetotem requires QuestData, LegendFrostwolf, FrostwolfSetup, GeneralHelpers 

  globals 
    private constant integer QUEST_RESEARCH_ID = 'R095' 
  endglobals 

  struct QuestRagetotem extends QuestData 

    private method operator CompletionPopup takes nothing returns string 
      return "Tales of Cairne's strength and wisdom reverberate throughout Kalimdor. As strength is drawn to strength, the Ragetotem are drawn to the Bloodhoof." 
    endmethod 

    private method operator CompletionDescription takes nothing returns string 
      return "Learn to train Tauren Gladiators from the Tauren Totem" 
    endmethod 

    private method OnComplete takes nothing returns nothing 
    endmethod 

    public static method create takes nothing returns thistype 
      local thistype this = thistype.allocate("Ragetotem Tribe", "The Ragetotem Tribe are renowned for their martial prowess. An older, mightier Cairne might convince them to join the Bloodhoof.", "ReplaceableTextures\\CommandButtons\\BTNGreatTaurenThieftain.blp") 
      call this.AddQuestItem(QuestItemLegendLevel.create(LEGEND_CAIRNE, 8)) 
      set this.ResearchId = QUEST_RESEARCH_ID 
      return this 
    endmethod 
  endstruct 

endlibrary