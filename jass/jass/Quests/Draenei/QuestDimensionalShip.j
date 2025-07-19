library QuestDimensionalShip requires DraeneiSetup, GeneralHelpers, QuestData, Artifact 

  globals 
    private constant integer QUEST_RESEARCH_ID = 'R08L' //This research is given when the quest is completed            
  endglobals 

  struct QuestDimensionalShip extends QuestData
    private Artifact targetArtifact
    private method operator Global takes nothing returns boolean 
      return true 
    endmethod 

    private method operator CompletionPopup takes nothing returns string 
      return "With the acquisition of a replacement power source, the Exodar's gemcrafters set to work on Lightforged structure." 
    endmethod 

    private method operator CompletionDescription takes nothing returns string 
      return "The Lightforged units and A'dal will become available." 
    endmethod 

    private method OnComplete takes nothing returns nothing
      call SetItemDroppableBJ(finalArtifact.item, false)
    endmethod 

    public static method create takes nothing returns thistype 
      local thistype this = thistype.allocate("The Dimensional Ship", "The core of the Exodar is rebuilt, but it requires a great source of power to function again. Finding that source of power would make the Exodar a powerful asset for the Draenei.", "ReplaceableTextures\\CommandButtons\\BTNArcaneEnergy.blp") 
      
      call this.AddQuestItem(QuestItemLegendHasAnyArtifact.create(LEGEND_EXODAR, ARTIFACT_EYEOFSARGERAS, ARTIFACT_CROWNTRIUMVIRATE, ARTIFACT_CROWNEASTERNKINGDOMS, ARTIFACT_SULFURAS, ARTIFACT_ZINROKH)) 
      call this.AddQuestItem(QuestItemTime.create(1200)) 
      call this.AddQuestItem(QuestItemLegendNotPermanentlyDead.create(LEGEND_VELEN)) 
      set this.ResearchId = QUEST_RESEARCH_ID 
      return this 
    endmethod 
  endstruct 

endlibrary