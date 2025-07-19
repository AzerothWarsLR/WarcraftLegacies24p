//If the Centaur Khan dies, OR a time elapses, give Thunder Bluff to a Horde player. 
library QuestHighmountain requires QuestData, LegendFrostwolf, FrostwolfSetup, GeneralHelpers 

  globals 
    private constant integer QUEST_RESEARCH_ID = 'R097' 
  endglobals 

  struct QuestHighmountain extends QuestData 

    private method operator CompletionPopup takes nothing returns string 
      return "Cairne is welcomed in Highmountain like a lost-long friend. Eager to explore the world and fight alongside their long-lost brethren, the Highmountain send their best hunters to support the Horde, and offer their home as a traveler's respite." 
    endmethod 

    private method operator CompletionDescription takes nothing returns string 
      return "Gain control of all units in Highmountain, and learn to train Wanderers from the Tauren Totem" 
    endmethod 

    private method OnComplete takes nothing returns nothing 
      call RescueNeutralUnitsInRect(gg_rct_highmountain, this.Holder.Player) 
    endmethod 

    public static method create takes nothing returns thistype 
      local thistype this = thistype.allocate("A Feast for Our Kin", "Scouts report sighting of the Highmountain totem, thought lost long ago when the Broken Isles were shattered. As a gesture of renewed welcome, Cairne might offer them an invitation to a feast in Thunderbluff.", "ReplaceableTextures\\CommandButtons\\BTNPigHead.blp") 
      call this.AddQuestItem(QuestItemLegendInRect.create(LEGEND_CAIRNE, gg_rct_highmountain, "Highmountain, north of Stormheim"))
      set this.ResearchId = QUEST_RESEARCH_ID 
      return this 
    endmethod 
  endstruct 

endlibrary