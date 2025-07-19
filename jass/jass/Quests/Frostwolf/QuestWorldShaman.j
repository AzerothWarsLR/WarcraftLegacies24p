library QuestWorldShaman requires QuestData, LegendFrostwolf, FrostwolfSetup, GeneralHelpers 

    struct QuestWorldShaman extends QuestData 
        private method operator CompletionPopup takes nothing returns string 
            return "Thrall has stabilized the power of the Maelstrom and stored it within the Doomhammer. He is no longer merely the Warchief of the Horde; he is the World-Shaman of all Azeroth." 
        endmethod 

        private method operator CompletionDescription takes nothing returns string 
            return "Thrall gains 2000 experience and 40 all stats and you gain the Power Maelstrom Spirit" 
        endmethod 

        private method OnComplete takes nothing returns nothing 
            call AddHeroAttributes(LEGEND_THRALL.Unit, 40, 40, 40) 
            call AddHeroXP(LEGEND_THRALL.Unit, 2000, true) 
            call EnableTrigger(gg_trg_light1) 
        endmethod 

        public static method create takes nothing returns thistype 
            local thistype this = thistype.allocate("The World-Shaman", "The elements of Azeroth are in terrible disarray, and the situation only grows worse as rising conflicts threaten to tear our world apart. Thrall, as one of the most formidable Shamans of his time, must take up the mantle of the World-Shaman if he is to save his people - and the world.", "ReplaceableTextures\\CommandButtons\\BTN_Lightning_Orc.blp") 
            call this.AddQuestItem(QuestItemTime.create(1500)) 
            call this.AddQuestItem(QuestItemControlPoint.create(ControlPoint.ByUnitType('n0A0'))) 
            call this.AddQuestItem(QuestItemChannelRect.create(gg_rct_worldshaman, "Maelstrom", LEGEND_THRALL, 180, 180)) 
            call this.AddQuestItem(QuestItemLegendLevel.create(LEGEND_THRALL, 8)) 
            return this 
        endmethod 
    endstruct 

endlibrary