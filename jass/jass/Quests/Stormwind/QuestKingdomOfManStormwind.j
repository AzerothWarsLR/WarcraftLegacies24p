library QuestKingdomOfManStormwind requires StormwindSetup, QuestItemControlPoint, GeneralHelpers

  globals
    private constant integer RESEARCH_ID = 'R01N'
    private constant integer EXPERIENCE_REWARD = 6000
  endglobals

  struct QuestKingdomOfManStormwind extends QuestData
    private method operator Global takes nothing returns boolean
      return true
    endmethod

    private method operator CompletionPopup takes nothing returns string
      return "The people of the Eastern Kingdoms have been united under the banner of Stormwind. Long live High King Varian Wrynn!"
    endmethod

    private method operator CompletionDescription takes nothing returns string
      return "You gain a research improving all of your units, the Crowns of Lordaeron and Stormwind are merged, and Varian gains " + I2S(EXPERIENCE_REWARD) + "."
    endmethod

    private method OnComplete takes nothing returns nothing
      //Artifact
      local unit crownHolder = ARTIFACT_CROWNSTORMWIND.OwningUnit
      call RemoveItem(ARTIFACT_CROWNLORDAERON.item)
      call RemoveItem(ARTIFACT_CROWNSTORMWIND.item)
      call UnitAddItemSafe(crownHolder, ARTIFACT_CROWNEASTERNKINGDOMS.item)
      call ARTIFACT_CROWNLORDAERON.setStatus(ARTIFACT_STATUS_HIDDEN)
      call ARTIFACT_CROWNLORDAERON.setDescription("Melted down")
      call ARTIFACT_CROWNSTORMWIND.setStatus(ARTIFACT_STATUS_HIDDEN)
      call ARTIFACT_CROWNSTORMWIND.setDescription("Melted down")
      //Research
      call SetPlayerTechResearched(Holder.Player, RESEARCH_ID, 1)
      call DisplayResearchAcquired(Holder.Player, RESEARCH_ID, 1)
      //High King Arthas
      call BlzSetUnitName(LEGEND_VARIAN.Unit, "High King")
      call AddHeroXP(LEGEND_VARIAN.Unit, EXPERIENCE_REWARD, true)
    endmethod

    private method OnAdd takes nothing returns nothing
      call Holder.ModObjectLimit(RESEARCH_ID, UNLIMITED)
    endmethod

    public static method create takes nothing returns thistype
      local thistype this = thistype.allocate("Kingdom of Man", "Before the First War, all of humanity was united under the banner of the Arathorian Empire. Reclaim its greatness by uniting mankind once again.", "ReplaceableTextures\\CommandButtons\\BTNFireKingCrown.blp")
      call this.AddQuestItem(QuestItemLegendNotPermanentlyDead.create(LEGEND_VARIAN))
      call this.AddQuestItem(QuestItemAcquireArtifact.create(ARTIFACT_CROWNLORDAERON))
      call this.AddQuestItem(QuestItemAcquireArtifact.create(ARTIFACT_CROWNSTORMWIND))
      call this.AddQuestItem(QuestItemControlLegend.create(LEGEND_BLACKTEMPLE, false))
      call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n010')))
      call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n01G')))
      return this
    endmethod
  endstruct

endlibrary