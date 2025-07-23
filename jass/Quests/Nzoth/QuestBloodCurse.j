library QuestBloodCurse requires QuestData, LegendNaga, NzothSetup, GeneralHelpers 

    globals 
        private constant integer QUEST_RESEARCH_ID = 'R098' 
    endglobals 
    
    struct QuestBloodCurse extends QuestData 
        private method operator CompletionPopup takes nothing returns string 
            return "TThe Bloodcursed Naga has been liberated, and Atoph the Bloodcursed has joined the Nazjatar Empire." 
        endmethod 

        private method operator CompletionDescription takes nothing returns string 
            return "Azshara gains 1000 experience and 10 all stats and you can train Atoph the Bloodcursed." 
        endmethod 

        private method OnComplete takes nothing returns nothing 
            call AddHeroAttributes(LEGEND_AZSHARA.Unit, 10, 10, 10) 
            call AddHeroXP(LEGEND_AZSHARA.Unit, 1000, true) 
        endmethod 

        public static method create takes nothing returns thistype 
            local thistype this = thistype.allocate("The Bloodcursed Naga", "Atoph the Bloodcursed is the leader of the Bloodcursed naga and defends the shrine of Queen Azshara on the Bloodcurse Isle from any who would seek to destroy it.", "ReplaceableTextures\\CommandButtons\\BTNRoyalGuardHeroV2.blp") 
            call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n02Z'))) 
            call this.AddQuestItem(QuestItemLegendLevel.create(LEGEND_AZSHARA, 8)) 
            set this.ResearchId = QUEST_RESEARCH_ID 
            return this 
        endmethod 
    endstruct 

endlibrary